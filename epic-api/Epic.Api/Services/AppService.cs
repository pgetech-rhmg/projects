using Epic.Api.Auth;
using Epic.Api.Data;
using Epic.Api.Data.Entities;
using Epic.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Epic.Api.Services;

public sealed class AppService(EpicDbContext db, IGitHubService gitHub, IAdoService ado, ICurrentUser currentUser, ILogger<AppService> logger) : IAppService
{
    private string CurrentUserId => currentUser.UserId;

    public async Task<List<ManagedApp>> GetUserAppsAsync(CancellationToken ct = default)
    {
        var userApps = await db.UserApps
            .Where(ua => ua.UserId == CurrentUserId)
            .Include(ua => ua.App)
                .ThenInclude(a => a.Runs.OrderByDescending(r => r.StartedAt))
            .ToListAsync(ct);

        // Lightweight refresh — fetch recent runs per app from ADO (no timeline/stage detail)
        var apps = userApps.Select(ua => ua.App).ToList();
        var lastRunTags = await RefreshRecentRunsFromAdoAsync(apps, ct);

        var stats = await GetRunStatsAsync(apps, ct);

        return apps.Select(a => ToManagedApp(a, stats.GetValueOrDefault(a.Name), lastRunTags.GetValueOrDefault(a.Name))).ToList();
    }

    private async Task<Dictionary<string, (int Total, int Successful, TimeSpan TotalDuration)>> GetRunStatsAsync(
        List<AppEntity> apps, CancellationToken ct)
    {
        try
        {
            var tasks = apps.Select(async app =>
            {
                var stats = await ado.GetCompletedRunCountsAsync(app.GithubRepo, ct);
                return (app.Name, stats);
            });
            var results = await Task.WhenAll(tasks);
            return results.ToDictionary(r => r.Name, r => r.stats);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "ADO unavailable during run stats — serving stale data");
            return [];
        }
    }

    public async Task<AppDetail?> GetAppAsync(string name, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == name, ct);
        if (entity is null) return null;

        // Refresh metadata from GitHub. Runs are now loaded separately via the
        // paged /runs endpoint, so the modal can fetch only the active page.
        await RefreshFromGitHubAsync(entity, ct);

        var statsTask = GetRunStatsAsync([entity], ct);

        // Fetch latest run's tags for technology/cloud
        var recent = await ado.GetRecentRunsForAppAsync(entity.GithubRepo, 1, ct);
        var latest = recent.MaxBy(r => r.StartedAt);

        var stats = (await statsTask).GetValueOrDefault(entity.Name);
        var successRate = stats.Total > 0
            ? Math.Round((double)stats.Successful / stats.Total * 100, 2)
            : (double?)null;
        var avgDuration = stats.Total > 0
            ? FormatDurationFromTimeSpan(stats.TotalDuration / stats.Total)
            : null;

        var detail = ToAppDetail(entity, successRate, avgDuration);
        detail.Technology = latest?.AppType is not null ? MapAppTypeToTechnology(latest.AppType) : "-";
        detail.Cloud = latest?.Cloud is not null ? MapCloud(latest.Cloud) : "-";
        return detail;
    }

    public async Task<PipelineRunPage?> GetRunsPageAsync(string name, int page, int pageSize, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == name, ct);
        if (entity is null) return null;

        try
        {
            var adoPage = await ado.GetRunsPageAsync(entity.GithubRepo, page, pageSize, ct);

            return new PipelineRunPage
            {
                Total = adoPage.Total,
                Page = page,
                PageSize = pageSize,
                Runs = adoPage.Runs.Select(r => new PipelineRun
                {
                    Id = r.Id,
                    OrchestratorId = r.OrchestratorId,
                    Status = Enum.Parse<RunStatus>(r.Status, true),
                    TriggeredBy = r.TriggeredBy,
                    Branch = r.Branch,
                    Cloud = r.Cloud is not null ? MapCloud(r.Cloud) : "-",
                    Environment = r.Environment,
                    AppName = r.AppName,
                    StartedAt = r.StartedAt.ToString("o"),
                    Duration = r.Duration,
                    Stages = r.Stages
                }).ToList()
            };
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "ADO unavailable during paged runs fetch for {AppName}", entity.Name);
            return new PipelineRunPage { Total = 0, Page = page, PageSize = pageSize, Runs = [] };
        }
    }

    public async Task<StageDetail?> GetStageDetailAsync(string appName, int runId, string stageName, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct);
        if (entity is null) return null;

        return await ado.GetStageDetailAsync(runId, stageName, ct);
    }

    public async Task<string?> GetStepLogAsync(string appName, int runId, int logId, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct);
        if (entity is null) return null;

        return await ado.GetStepLogAsync(runId, logId, ct);
    }

    private async Task<Dictionary<string, (string? Cloud, string? Environment, string? AppType, string? AppName)>> RefreshRecentRunsFromAdoAsync(List<AppEntity> apps, CancellationToken ct)
    {
        var lastRunTags = new Dictionary<string, (string? Cloud, string? Environment, string? AppType, string? AppName)>();

        try
        {
            // Fetch recent runs for each app in parallel (up to 20, no stage timelines)
            var tasks = apps.Select(async app =>
            {
                var recent = await ado.GetRecentRunsForAppAsync(app.GithubRepo, 20, ct);
                return (app, recent);
            });

            var results = await Task.WhenAll(tasks);
            var hasChanges = false;

            foreach (var (app, recent) in results)
            {
                if (recent.Count == 0) continue;

                // Track the latest run's cloud/environment/appType/appName from ADO tags
                var latest = recent.MaxBy(r => r.StartedAt);
                if (latest is not null)
                    lastRunTags[app.Name] = (latest.Cloud, latest.Environment, latest.AppType, latest.AppName);

                var existingById = app.Runs.ToDictionary(r => r.Id);

                foreach (var run in recent)
                {
                    if (existingById.TryGetValue(run.Id, out var existing))
                    {
                        // Update status / duration / triggeredBy if changed
                        if (existing.Status != run.Status
                            || existing.Duration != run.Duration
                            || existing.TriggeredBy != run.TriggeredBy)
                        {
                            existing.Status = run.Status;
                            existing.Duration = run.Duration;
                            existing.TriggeredBy = run.TriggeredBy;
                            hasChanges = true;
                        }
                    }
                    else
                    {
                        // New run we haven't seen — add a lightweight record (no stage detail)
                        app.Runs.Add(new PipelineRunEntity
                        {
                            Id = run.Id,
                            AppId = app.Id,
                            Status = run.Status,
                            TriggeredBy = run.TriggeredBy,
                            Branch = run.Branch,
                            Environment = run.Environment,
                            StartedAt = run.StartedAt,
                            Duration = run.Duration,
                            StageBuild = "Skipped",
                            StageTest = "Skipped",
                            StageScan = "Skipped",
                            StageInfraDeploy = "Skipped",
                            StageAppDeploy = "Skipped",
                            StageIntegrationTest = "Skipped"
                        });
                        hasChanges = true;
                    }
                }
            }

            if (hasChanges)
                await db.SaveChangesAsync(ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "ADO unavailable during recent runs refresh — serving stale data");
        }

        return lastRunTags;
    }

    private async Task RefreshFromGitHubAsync(AppEntity entity, CancellationToken ct)
    {
        try
        {
            var repoInfo = await gitHub.GetRepoAsync(entity.GithubRepo, ct);
            if (!repoInfo.Exists) return;

            var hasChanges = false;

            if (repoInfo.Description is not null && entity.Description != repoInfo.Description)
            {
                entity.Description = repoInfo.Description;
                hasChanges = true;
            }

            // Re-check .infra/ folder existence
            var hasInfra = await gitHub.PathExistsAsync(entity.GithubRepo, ".infra", entity.GithubBranch, ct);
            if (entity.HasInfra != hasInfra)
            {
                entity.HasInfra = hasInfra;
                hasChanges = true;
            }

            if (hasChanges)
            {
                entity.LastUpdatedAt = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
            }
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "GitHub unavailable during refresh for {Repo} — serving stale data", entity.GithubRepo);
        }
    }

    public async Task<RepoCheckResult> CheckRepoAsync(string repo, CancellationToken ct = default)
    {
        var app = await db.Apps.FirstOrDefaultAsync(a => a.GithubRepo == repo, ct);

        if (app is null)
        {
            var repoInfo = await gitHub.GetRepoAsync(repo, ct);
            return new RepoCheckResult
            {
                Status = repoInfo.Exists ? "available" : "not-found"
            };
        }

        var isTracked = await db.UserApps
            .AnyAsync(ua => ua.UserId == CurrentUserId && ua.AppId == app.Id, ct);

        if (isTracked)
        {
            return new RepoCheckResult
            {
                Status = "already-mine",
                MasterApp = ToAppLookup(app)
            };
        }

        return new RepoCheckResult
        {
            Status = "in-epic-not-mine",
            MasterApp = ToAppLookup(app)
        };
    }

    public async Task<ManagedApp> AddToMyAppsAsync(string name, CancellationToken ct = default)
    {
        var app = await db.Apps
            .Include(a => a.Runs.OrderByDescending(r => r.StartedAt).Take(1))
            .FirstOrDefaultAsync(a => a.Name == name, ct)
            ?? throw new KeyNotFoundException($"App '{name}' not found");

        db.UserApps.Add(new UserAppEntity
        {
            UserId = CurrentUserId,
            AppId = app.Id
        });

        await db.SaveChangesAsync(ct);

        var lastRunTags = await RefreshRecentRunsFromAdoAsync([app], ct);
        var stats = (await GetRunStatsAsync([app], ct)).GetValueOrDefault(app.Name);

        return ToManagedApp(app, stats, lastRunTags.GetValueOrDefault(app.Name));
    }

    public async Task<AppDetail> OnboardAppAsync(string repo, CancellationToken ct = default)
    {
        var repoInfo = await gitHub.GetRepoAsync(repo, ct);
        if (!repoInfo.Exists)
            throw new KeyNotFoundException($"GitHub repo '{repo}' not found");

        var resolvedBranch = repoInfo.DefaultBranch ?? "main";

        var hasInfra = await gitHub.PathExistsAsync(repo, ".infra", resolvedBranch, ct);

        var appType = MapTechnologyToAppType(MapLanguageToTechnology(repoInfo.Language));
        var technology = MapAppTypeToTechnology(appType);
        var appName = repo.ToLowerInvariant();

        var entity = new AppEntity
        {
            Name = appName,
            DisplayName = FormatDisplayName(appName),
            Description = repoInfo.Description,
            AppType = appType,
            Technology = technology,
            Cloud = "AWS",
            Environment = "dev",
            Team = "unassigned",
            Domain = "",
            GithubRepo = repo,
            GithubBranch = resolvedBranch,
            HasInfra = hasInfra,
            CreatedBy = CurrentUserId,
            LastUpdatedBy = CurrentUserId
        };

        db.Apps.Add(entity);

        db.UserApps.Add(new UserAppEntity
        {
            UserId = CurrentUserId,
            App = entity
        });

        await db.SaveChangesAsync(ct);

        await RefreshRecentRunsFromAdoAsync([entity], ct);

        return ToAppDetail(entity);
    }

    private static string MapLanguageToTechnology(string? language) => language?.ToLowerInvariant() switch
    {
        "typescript" or "javascript" => "Angular",
        "c#" => ".NET",
        "python" => "Python",
        "java" or "kotlin" => "Java",
        "hcl" => "Terraform",
        "html" or "css" => "HTML",
        "go" => "Go",
        "ruby" => "Ruby",
        "shell" or "dockerfile" => "Shell",
        _ => language ?? "Unknown"
    };

    private static string MapTechnologyToAppType(string technology) => technology switch
    {
        "Angular" => "angular",
        "React" => "react",
        ".NET" => "dotnet",
        "Python" => "python",
        "Java" => "java",
        "HTML" => "html",
        "Terraform" => "hcl",
        _ => "unknown"
    };

    private static string MapAppTypeToTechnology(string appType) => appType switch
    {
        "angular" => "Angular",
        "react" => "React",
        "dotnet" or "dotnet_framework" => ".NET",
        "python" => "Python",
        "java" => "Java",
        "html" => "HTML",
        "hcl" => "Terraform",
        "ami" => "AMI",
        "btp" => "SAP",
        "cap" => "SAP",
        "infra" => "Terraform",
        _ => appType
    };

    private static string MapCloud(string? cloud) => cloud?.ToLowerInvariant() switch
    {
        "aws" => "AWS",
        "azure" => "Azure",
        "btp" => "BTP",
        _ => cloud ?? "AWS"
    };

    private static string FormatDisplayName(string repo) =>
        string.Join(' ', repo.Split('-', '_')
            .Select(w => w.Length > 0 ? char.ToUpper(w[0]) + w[1..] : w));

    public async Task RemoveFromMyAppsAsync(string name, CancellationToken ct = default)
    {
        var app = await db.Apps.FirstOrDefaultAsync(a => a.Name == name, ct)
            ?? throw new KeyNotFoundException($"App '{name}' not found");

        var userApp = await db.UserApps
            .FirstOrDefaultAsync(ua => ua.UserId == CurrentUserId && ua.AppId == app.Id, ct)
            ?? throw new KeyNotFoundException($"App '{name}' is not in your list");

        db.UserApps.Remove(userApp);
        await db.SaveChangesAsync(ct);
    }

    public async Task<TriggerRunResponse> TriggerRunAsync(
        string appName, string branch, string environment, string config,
        bool build, bool tests, bool scan, bool deploy, bool integrations,
        string deployInfra, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct)
            ?? throw new KeyNotFoundException($"App '{appName}' not found");

        var result = await ado.TriggerOrchestratorAsync(
            entity.GithubRepo, branch, environment, config.TrimStart('/'),
            build, tests, scan, deploy, integrations, deployInfra, ct);

        return new TriggerRunResponse
        {
            RunId = result.RunId,
            Url = result.Url
        };
    }

    public async Task CancelRunAsync(string appName, int runId, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct)
            ?? throw new KeyNotFoundException($"App '{appName}' not found");

        // A logical run is two ADO builds: a fire-and-forget orchestrator that triggers an
        // engine build. The id the UI shows (runId) is the engine build in steady state, or
        // the orchestrator build while the engine hasn't been triggered yet. To cancel
        // reliably — and to close the race where the user clicks during the orchestrator→engine
        // transition — we resolve the orchestrator/engine pair from fresh ADO state and cancel
        // both. CancelBuildAsync is idempotent, so cancelling an already-finished build is a no-op.
        var buildIds = new HashSet<int> { runId };
        try
        {
            var page = await ado.GetRunsPageAsync(entity.GithubRepo, 1, 50, ct);
            var match = page.Runs.FirstOrDefault(r => r.Id == runId || r.OrchestratorId == runId);
            if (match is not null)
            {
                buildIds.Add(match.Id);
                if (match.OrchestratorId.HasValue) buildIds.Add(match.OrchestratorId.Value);
            }
        }
        catch (Exception ex)
        {
            // ADO unavailable — fall back to cancelling just the id we were given.
            logger.LogWarning(ex, "Could not resolve orchestrator/engine pair for run {RunId}; cancelling that build only", runId);
        }

        foreach (var buildId in buildIds)
            await ado.CancelBuildAsync(buildId, ct);

        // Update local DB record if we have it (match on either build id of the pair)
        var run = await db.Set<PipelineRunEntity>()
            .FirstOrDefaultAsync(r => buildIds.Contains(r.Id) && r.AppId == entity.Id, ct);
        if (run is not null)
        {
            run.Status = "Canceled";
            await db.SaveChangesAsync(ct);
        }
    }

    public async Task<List<string>> FindConfigsAsync(string repo, string branch, CancellationToken ct = default)
    {
        return await gitHub.FindEpicConfigsAsync(repo, branch, ct);
    }

    public async Task<ConfigCheckResult> CheckConfigInfraAsync(string repo, string branch, string configPath, CancellationToken ct = default)
    {
        return await gitHub.CheckInfraAsync(repo, branch, configPath, ct);
    }

    // ----- Mapping helpers -----

    private static ManagedApp ToManagedApp(AppEntity entity, (int Total, int Successful, TimeSpan TotalDuration) stats, (string? Cloud, string? Environment, string? AppType, string? AppName) lastRunTags = default)
    {
        var lastRun = entity.Runs.MaxBy(r => r.StartedAt);

        return new ManagedApp
        {
            Name = entity.Name,
            AppName = lastRunTags.AppName,
            Technology = lastRunTags.AppType is not null ? MapAppTypeToTechnology(lastRunTags.AppType) : "-",
            Cloud = lastRunTags.Cloud is not null ? MapCloud(lastRunTags.Cloud) : "-",
            Environment = lastRunTags.Environment ?? "-",
            LastPipelineRun = lastRun?.StartedAt.ToString("o"),
            Branch = lastRun?.Branch,
            RunId = lastRun?.Id,
            RunStatus = lastRun is not null ? Enum.Parse<RunStatus>(lastRun.Status, true) : null,
            TriggeredBy = lastRun?.TriggeredBy,
            SuccessRate = stats.Total > 0 ? Math.Round((double)stats.Successful / stats.Total * 100, 2) : null,
            AvgDuration = stats.Total > 0 ? FormatDurationFromTimeSpan(stats.TotalDuration / stats.Total) : null
        };
    }

    private static string FormatDurationFromTimeSpan(TimeSpan ts)
    {
        if (ts.TotalHours >= 1)
            return $"{(int)ts.TotalHours}h {ts.Minutes}m";
        if (ts.TotalMinutes >= 1)
            return $"{(int)ts.TotalMinutes}m {ts.Seconds}s";
        return $"{ts.Seconds}s";
    }

    private static AppLookup ToAppLookup(AppEntity entity) => new()
    {
        Name = entity.Name,
        DisplayName = entity.DisplayName,
        Technology = entity.Technology,
        Cloud = entity.Cloud,
        Environment = entity.Environment,
        Github = new GitHubInfo { Repo = entity.GithubRepo }
    };

    private static AppDetail ToAppDetail(AppEntity entity, double? successRate = null, string? avgDuration = null) => new()
    {
        SuccessRate = successRate,
        AvgDuration = avgDuration,
        Name = entity.Name,
        DisplayName = entity.DisplayName,
        Description = entity.Description,
        AppType = entity.AppType,
        Technology = entity.Technology,
        NodeVersion = entity.NodeVersion,
        PythonVersion = entity.PythonVersion,
        JavaVersion = entity.JavaVersion,
        DotnetVersion = entity.DotnetVersion,
        Cloud = entity.Cloud,
        Environment = entity.Environment,
        Team = entity.Team,
        LastUpdatedBy = entity.LastUpdatedBy,
        Domain = entity.Domain,
        HasInfra = entity.HasInfra,
        Github = new GitHubInfo
        {
            Repo = entity.GithubRepo,
            Branch = entity.GithubBranch
        },
        Aws = entity.AwsAccountId is not null
            ? new AwsConfig
            {
                AccountId = entity.AwsAccountId,
                S3 = entity.AwsS3,
                Cloudfront = entity.AwsCloudfront,
                Ec2InstanceId = entity.AwsEc2InstanceId
            }
            : null,
        Azure = entity.AzureSubscription is not null
            ? new AzureConfig
            {
                Subscription = entity.AzureSubscription,
                ResourceGroup = entity.AzureResourceGroup!
            }
            : null
    };
}
