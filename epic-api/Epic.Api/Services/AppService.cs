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

        // Lightweight refresh — fetch latest run per app from ADO (no timeline/stage detail)
        await RefreshLatestRunsFromAdoAsync(userApps.Select(ua => ua.App).ToList(), ct);

        return userApps.Select(ua => ToManagedApp(ua.App)).ToList();
    }

    public async Task<AppDetail?> GetAppAsync(string name, CancellationToken ct = default)
    {
        var entity = await db.Apps
            .Include(a => a.Runs.OrderByDescending(r => r.StartedAt))
            .FirstOrDefaultAsync(a => a.Name == name, ct);

        if (entity is null) return null;

        // Refresh metadata from GitHub and runs from ADO
        await RefreshFromGitHubAsync(entity, ct);
        await RefreshRunsFromAdoAsync(entity, ct);

        return ToAppDetail(entity);
    }

    private async Task RefreshLatestRunsFromAdoAsync(List<AppEntity> apps, CancellationToken ct)
    {
        try
        {
            // Fetch latest run for each app in parallel
            var tasks = apps.Select(async app =>
            {
                var latest = await ado.GetLatestRunForAppAsync(app.Name, ct);
                return (app, latest);
            });

            var results = await Task.WhenAll(tasks);
            var hasChanges = false;

            foreach (var (app, latest) in results)
            {
                if (latest is null) continue;

                var existingRun = app.Runs.FirstOrDefault();

                if (existingRun is null || existingRun.Id != latest.Id)
                {
                    // New run we haven't seen — add a lightweight record
                    if (!app.Runs.Any(r => r.Id == latest.Id))
                    {
                        app.Runs.Add(new PipelineRunEntity
                        {
                            Id = latest.Id,
                            AppId = app.Id,
                            Status = latest.Status,
                            TriggeredBy = latest.TriggeredBy,
                            Branch = latest.Branch,
                            Environment = latest.Environment,
                            StartedAt = latest.StartedAt,
                            Duration = latest.Duration,
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
                else if (existingRun.Status != latest.Status)
                {
                    // Existing run changed status (e.g., Running → Success)
                    existingRun.Status = latest.Status;
                    existingRun.Duration = latest.Duration;
                    existingRun.TriggeredBy = latest.TriggeredBy;
                    hasChanges = true;
                }
            }

            if (hasChanges)
                await db.SaveChangesAsync(ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "ADO unavailable during latest run refresh — serving stale data");
        }
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

    private async Task RefreshRunsFromAdoAsync(AppEntity entity, CancellationToken ct)
    {
        try
        {
            // Find the latest completed run ID we have — only fetch newer ones
            // But also re-check any "Running" runs we have in case they've finished
            var latestCompletedId = entity.Runs
                .Where(r => r.Status != "Running")
                .Select(r => r.Id)
                .DefaultIfEmpty(0)
                .Max();

            var adoRuns = await ado.GetRunsForAppAsync(entity.Name, latestCompletedId > 0 ? latestCompletedId : null, 20, ct);
            if (adoRuns.Count == 0) return;

            var existingRunIds = entity.Runs.Select(r => r.Id).ToHashSet();
            var hasChanges = false;

            foreach (var run in adoRuns)
            {
                if (existingRunIds.Contains(run.Id))
                {
                    var existing = entity.Runs.First(r => r.Id == run.Id);
                    if (existing.Status != run.Status)
                    {
                        existing.Status = run.Status;
                        existing.Duration = run.Duration;
                        existing.StageBuild = run.Stages.Build.ToString();
                        existing.StageTest = run.Stages.Test.ToString();
                        existing.StageScan = run.Stages.Scan.ToString();
                        existing.StageInfraDeploy = run.Stages.InfraDeploy.ToString();
                        existing.StageAppDeploy = run.Stages.AppDeploy.ToString();
                        existing.StageIntegrationTest = run.Stages.IntegrationTest.ToString();
                        hasChanges = true;
                    }
                }
                else
                {
                    entity.Runs.Add(new PipelineRunEntity
                    {
                        Id = run.Id,
                        AppId = entity.Id,
                        Status = run.Status,
                        TriggeredBy = run.TriggeredBy,
                        Branch = run.Branch,
                        Environment = run.Environment,
                        StartedAt = run.StartedAt,
                        Duration = run.Duration,
                        StageBuild = run.Stages.Build.ToString(),
                        StageTest = run.Stages.Test.ToString(),
                        StageScan = run.Stages.Scan.ToString(),
                        StageInfraDeploy = run.Stages.InfraDeploy.ToString(),
                        StageAppDeploy = run.Stages.AppDeploy.ToString(),
                        StageIntegrationTest = run.Stages.IntegrationTest.ToString()
                    });
                    hasChanges = true;
                }
            }

            if (hasChanges)
            {
                await db.SaveChangesAsync(ct);
                // Reload runs sorted after save
                entity.Runs = entity.Runs.OrderByDescending(r => r.StartedAt).ToList();
            }
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "ADO unavailable during run refresh for {AppName} — serving stale data", entity.Name);
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

        // Refresh latest run from ADO
        await RefreshLatestRunsFromAdoAsync([app], ct);

        return ToManagedApp(app);
    }

    public async Task<AppDetail> OnboardAppAsync(string repo, string branch, CancellationToken ct = default)
    {
        var repoInfo = await gitHub.GetRepoAsync(repo, ct);
        if (!repoInfo.Exists)
            throw new KeyNotFoundException($"GitHub repo '{repo}' not found");

        var resolvedBranch = branch.Length > 0 ? branch : repoInfo.DefaultBranch ?? "main";

        // Read epic.json from the repo — required for onboarding
        var epicJson = await gitHub.GetFileContentAsync(repo, ".pipeline/epic.json", resolvedBranch, ct);
        if (epicJson is null)
            throw new InvalidOperationException($"Repository '{repo}' on branch '{resolvedBranch}' does not have a .pipeline/epic.json file and is not configured for EPIC.");

        string? epicAppName = null;
        string? epicAppType = null;
        string? epicCloud = null;
        try
        {
            var config = System.Text.Json.JsonDocument.Parse(epicJson).RootElement;
            var appSection = config.TryGetProperty("app", out var app) ? app : config;
            epicAppName = appSection.TryGetProperty("appName", out var an) ? an.GetString() : null;
            epicAppType = appSection.TryGetProperty("appType", out var at) ? at.GetString() : null;
            epicCloud = config.TryGetProperty("cloud", out var cl)
                && cl.TryGetProperty("awsAccountId", out _) ? "aws"
                : config.TryGetProperty("cloud", out var cl2)
                    && cl2.TryGetProperty("azureSubscription", out _) ? "azure" : null;
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Failed to parse epic.json for {Repo} — using defaults", repo);
        }

        // Check if .infra/ folder exists
        var hasInfra = await gitHub.PathExistsAsync(repo, ".infra", resolvedBranch, ct);

        var appType = epicAppType ?? MapTechnologyToAppType(MapLanguageToTechnology(repoInfo.Language));
        var technology = MapAppTypeToTechnology(appType);
        var appName = epicAppName ?? repo.ToLowerInvariant();

        var entity = new AppEntity
        {
            Name = appName,
            DisplayName = FormatDisplayName(appName),
            Description = repoInfo.Description,
            AppType = appType,
            Technology = technology,
            Cloud = MapCloud(epicCloud),
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

        // Fetch latest run from ADO so the main table shows run data immediately
        await RefreshLatestRunsFromAdoAsync([entity], ct);

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
        ".NET" => "dotnet",
        "Python" => "python",
        "Java" => "java",
        "HTML" => "html",
        _ => "unknown"
    };

    private static string MapAppTypeToTechnology(string appType) => appType switch
    {
        "angular" => "Angular",
        "dotnet" or "dotnet_framework" => ".NET",
        "python" => "Python",
        "java" => "Java",
        "html" => "HTML",
        "ami" => "AMI",
        _ => appType
    };

    private static string MapCloud(string? cloud) => cloud?.ToLowerInvariant() switch
    {
        "aws" => "AWS",
        "azure" => "Azure",
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
        string appName, string branch, string environment,
        bool build, bool tests, bool scan, bool deploy, bool integrations,
        string deployInfra, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct)
            ?? throw new KeyNotFoundException($"App '{appName}' not found");

        var result = await ado.TriggerOrchestratorAsync(
            entity.GithubRepo, branch, environment,
            build, tests, scan, deploy, integrations, deployInfra, ct);

        return new TriggerRunResponse
        {
            RunId = result.RunId,
            Url = result.Url
        };
    }

    // ----- Mapping helpers -----

    private static ManagedApp ToManagedApp(AppEntity entity)
    {
        var lastRun = entity.Runs.MaxBy(r => r.StartedAt);
        var totalRuns = entity.Runs.Count;
        var successfulRuns = entity.Runs.Count(r => r.Status.Equals("Success", StringComparison.OrdinalIgnoreCase));

        return new ManagedApp
        {
            Name = entity.Name,
            Technology = entity.Technology,
            Cloud = entity.Cloud,
            Environment = entity.Environment,
            LastPipelineRun = lastRun?.StartedAt.ToString("o"),
            Branch = lastRun?.Branch,
            RunStatus = lastRun is not null ? Enum.Parse<RunStatus>(lastRun.Status, true) : null,
            TriggeredBy = lastRun?.TriggeredBy,
            SuccessRate = totalRuns > 0 ? Math.Round((double)successfulRuns / totalRuns * 100, 2) : null
        };
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

    private static AppDetail ToAppDetail(AppEntity entity) => new()
    {
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
            : null,
        Runs = entity.Runs.Select(r => new PipelineRun
        {
            Id = r.Id,
            Status = Enum.Parse<RunStatus>(r.Status, true),
            TriggeredBy = r.TriggeredBy,
            Branch = r.Branch,
            Environment = r.Environment,
            StartedAt = r.StartedAt.ToString("o"),
            Duration = r.Duration,
            Stages = new PipelineStages
            {
                Build = Enum.Parse<RunStatus>(r.StageBuild, true),
                Test = Enum.Parse<RunStatus>(r.StageTest, true),
                Scan = Enum.Parse<RunStatus>(r.StageScan, true),
                InfraDeploy = Enum.Parse<RunStatus>(r.StageInfraDeploy, true),
                AppDeploy = Enum.Parse<RunStatus>(r.StageAppDeploy, true),
                IntegrationTest = Enum.Parse<RunStatus>(r.StageIntegrationTest, true)
            }
        }).ToList()
    };
}
