using Epic.Api.Auth;
using Epic.Api.Data;
using Epic.Api.Data.Entities;
using Epic.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Epic.Api.Services;

public sealed class AppService(EpicDbContext db, IGitHubService gitHub, IGitHubSourceRegistry sources, IAdoService ado, ICurrentUser currentUser, IAuditLog audit, ILogger<AppService> logger) : IAppService
{
    // Display technology shared by the hcl/infra appTypes (and its reverse map).
    private const string TechnologyTerraform = "Terraform";

    // Shown when a run has no resolvable appType (e.g. a contract-less
    // Review-only run with no epic.json) — a blank cell would look like a bug.
    private const string TechnologyUnknown = "[UNKNOWN]";

    // Stable identity key (corpId) — scopes which apps a user owns.
    private string CurrentUserId => currentUser.UserId;

    // Human-readable name for audit/display fields (CreatedBy, ADO triggeredBy).
    private string CurrentUserDisplayName => currentUser.DisplayName;

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

        // Fetch latest run's tags for technology/cloud. Guarded like every other
        // ADO read in this service: if ADO is down/slow, serve stale data (fall
        // back to the stored technology) instead of 500-ing the app detail.
        AdoLatestRun? latest = null;
        try
        {
            var recent = await ado.GetRecentRunsForAppAsync(entity.GithubRepo, 1, ct);
            latest = recent.MaxBy(r => r.StartedAt);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "ADO unavailable during app detail for {Repo} — serving stale data", entity.GithubRepo);
        }

        var stats = (await statsTask).GetValueOrDefault(entity.Name);
        var successRate = stats.Total > 0
            ? Math.Round((double)stats.Successful / stats.Total * 100, 2)
            : (double?)null;
        var avgDuration = stats.Total > 0
            ? FormatDurationFromTimeSpan(stats.TotalDuration / stats.Total)
            : null;

        var detail = ToAppDetail(entity, successRate, avgDuration);
        detail.Technology = latest is not null ? ResolveTechnology(latest.AppType, entity.Technology) : "-";
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

    public async Task<string?> GetScanResultUrlAsync(string appName, int runId, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct);
        if (entity is null) return null;

        return await ado.GetScanResultUrlAsync(runId, ct);
    }

    public async Task<string?> GetComplianceReportAsync(string appName, int runId, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct);
        if (entity is null) return null;

        return await ado.GetComplianceReportAsync(runId, ct);
    }

    public async Task<ComplianceSummary?> GetComplianceSummaryAsync(string appName, int runId, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct);
        if (entity is null) return null;

        return await ado.GetComplianceSummaryAsync(runId, ct);
    }

    public async Task<ComplianceReport?> GetComplianceReportJsonAsync(string appName, int runId, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct);
        if (entity is null) return null;

        return await ado.GetComplianceReportJsonAsync(runId, ct);
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
                        // New run we haven't seen — add a lightweight record (no stage
                        // detail). Every stage defaults to Skipped on the entity, so
                        // we don't restate them here.
                        app.Runs.Add(new PipelineRunEntity
                        {
                            Id = run.Id,
                            AppId = app.Id,
                            Status = run.Status,
                            TriggeredBy = run.TriggeredBy,
                            Branch = run.Branch,
                            Environment = run.Environment,
                            StartedAt = run.StartedAt,
                            Duration = run.Duration
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
            var repoInfo = await gitHub.GetRepoAsync(entity.GithubRepo, entity.GithubSource, ct);
            if (!repoInfo.Exists) return;

            var hasChanges = false;

            if (repoInfo.Description is not null && entity.Description != repoInfo.Description)
            {
                entity.Description = repoInfo.Description;
                hasChanges = true;
            }

            // Keep the GitHub-derived technology fresh — it's the Technology
            // fallback for contract-less runs (empty appType tag). Only overwrite
            // when GitHub actually reports a language, so we never clobber a good
            // value with "Unknown" during a transient/empty GitHub response.
            if (repoInfo.Language is not null)
            {
                var technology = MapLanguageToTechnology(repoInfo.Language);
                if (entity.Technology != technology)
                {
                    entity.Technology = technology;
                    hasChanges = true;
                }
            }

            // Re-check .infra/ folder existence
            var hasInfra = await gitHub.PathExistsAsync(entity.GithubRepo, ".infra", entity.GithubBranch, entity.GithubSource, ct);
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

    public async Task<RepoCheckResult> CheckRepoAsync(string repo, string? source = null, CancellationToken ct = default)
    {
        var sourceName = sources.Resolve(source).Name;
        var app = await db.Apps.FirstOrDefaultAsync(a => a.GithubRepo == repo && a.GithubSource == sourceName, ct);

        if (app is null)
        {
            var repoInfo = await gitHub.GetRepoAsync(repo, source, ct);
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

        // Idempotent: adding an app already in the caller's portfolio is a no-op
        // rather than a duplicate insert that violates the (UserId, AppId) unique
        // index (which would surface as an unhandled 500 / phantom CORS error).
        var alreadyInPortfolio = await db.UserApps
            .AnyAsync(ua => ua.UserId == CurrentUserId && ua.AppId == app.Id, ct);
        if (!alreadyInPortfolio)
        {
            db.UserApps.Add(new UserAppEntity
            {
                UserId = CurrentUserId,
                AppId = app.Id
            });
            await db.SaveChangesAsync(ct);
            audit.Record("app.add_to_my_apps", $"app:{app.Name}");
        }

        var lastRunTags = await RefreshRecentRunsFromAdoAsync([app], ct);
        var stats = (await GetRunStatsAsync([app], ct)).GetValueOrDefault(app.Name);

        return ToManagedApp(app, stats, lastRunTags.GetValueOrDefault(app.Name));
    }

    public async Task<AppDetail> OnboardAppAsync(string repo, string? source = null, CancellationToken ct = default)
    {
        var sourceName = sources.Resolve(source).Name;
        var repoInfo = await gitHub.GetRepoAsync(repo, source, ct);
        if (!repoInfo.Exists)
            throw new KeyNotFoundException($"GitHub repo '{repo}' not found");

        var resolvedBranch = repoInfo.DefaultBranch ?? "main";

        var hasInfra = await gitHub.PathExistsAsync(repo, ".infra", resolvedBranch, source, ct);

        var appType = MapTechnologyToAppType(MapLanguageToTechnology(repoInfo.Language));
        var technology = MapAppTypeToTechnology(appType);
        var appName = repo.ToLowerInvariant();

        // The app catalog (apps) is shared; a user's portfolio is the UserApps
        // join. "Remove from my apps" only deletes the join row, leaving the
        // catalog entry in place, so onboarding must be idempotent — re-adding a
        // repo re-attaches the join row to the existing catalog entry rather than
        // inserting a duplicate (which would violate the unique indexes on Name
        // and (GithubSource, GithubRepo) and surface as an unhandled 500).
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct);

        if (entity is null)
        {
            entity = new AppEntity
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
                GithubSource = sourceName,
                GithubBranch = resolvedBranch,
                HasInfra = hasInfra,
                CreatedBy = CurrentUserDisplayName,
                LastUpdatedBy = CurrentUserDisplayName
            };
            db.Apps.Add(entity);
        }
        else
        {
            // Refresh the catalog entry from the current GitHub state so re-adding
            // picks up anything that changed while it was out of the portfolio.
            entity.Description = repoInfo.Description;
            entity.GithubSource = sourceName;
            entity.GithubBranch = resolvedBranch;
            entity.HasInfra = hasInfra;
            entity.LastUpdatedBy = CurrentUserDisplayName;
        }

        // Only attach a join row if this user doesn't already have one, so
        // onboarding an app that's still in the caller's portfolio is a no-op
        // rather than a unique-index violation on (UserId, AppId).
        var alreadyInPortfolio = entity.Id != 0 && await db.UserApps
            .AnyAsync(ua => ua.UserId == CurrentUserId && ua.AppId == entity.Id, ct);
        if (!alreadyInPortfolio)
        {
            db.UserApps.Add(new UserAppEntity
            {
                UserId = CurrentUserId,
                App = entity
            });
        }

        await db.SaveChangesAsync(ct);
        audit.Record("app.onboard", $"app:{entity.Name}", detail: $"repo={repo}");

        await RefreshRecentRunsFromAdoAsync([entity], ct);

        return ToAppDetail(entity);
    }

    private static string MapLanguageToTechnology(string? language) => language?.ToLowerInvariant() switch
    {
        "typescript" or "javascript" => "Angular",
        "c#" => ".NET",
        "python" => "Python",
        "java" or "kotlin" => "Java",
        "hcl" => TechnologyTerraform,
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
        TechnologyTerraform => "hcl",
        _ => "unknown"
    };

    /// <summary>
    /// Technology shown in the dashboard. Prefer the last run's tagged appType.
    /// A contract-less Review-only run (no epic.json) tags an empty appType, so
    /// fall back to the primary language EPIC recorded from GitHub, and only show
    /// [UNKNOWN] when even that is unavailable — never a blank cell.
    /// </summary>
    private static string ResolveTechnology(string? runAppType, string? githubTechnology)
    {
        if (!string.IsNullOrWhiteSpace(runAppType))
            return MapAppTypeToTechnology(runAppType);
        if (!string.IsNullOrWhiteSpace(githubTechnology))
            return githubTechnology;
        return TechnologyUnknown;
    }

    private static string MapAppTypeToTechnology(string appType) => appType switch
    {
        "angular" => "Angular",
        "react" => "React",
        "dotnet" or "dotnet_framework" => ".NET",
        "python" => "Python",
        "java" => "Java",
        "go" => "Go",
        "html" => "HTML",
        "hcl" => TechnologyTerraform,
        "ami" => "AMI",
        "btp" => "SAP BTP",
        "cap" => "SAP CAP",
        "infra" => TechnologyTerraform,
        _ => appType
    };

    /// <summary>Maps an ADO cloud tag to its display value.</summary>
    /// <remarks>
    /// Legacy pipeline runs (pre-2026-06) tagged the cloud provider as "btp";
    /// current runs tag it "sap". Both map to SAP so historical tags stay
    /// connected to the same display value as new ones.
    /// </remarks>
    private static string MapCloud(string? cloud) => cloud?.ToLowerInvariant() switch
    {
        "aws" => "AWS",
        "azure" => "Azure",
        "btp" or "sap" => "SAP",
        _ => cloud ?? "AWS"
    };

    private static readonly char[] DisplayNameSeparators = ['-', '_'];

    private static string FormatDisplayName(string repo) =>
        string.Join(' ', repo.Split(DisplayNameSeparators)
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
        audit.Record("app.remove_from_my_apps", $"app:{name}");
    }

    public async Task<TriggerRunResponse> TriggerRunAsync(
        string appName, string branch, string environment, string config,
        bool review, bool build, bool tests, bool scan, bool deploy, bool integrations,
        string deployInfra, bool forceStateCopy, CancellationToken ct = default)
    {
        var entity = await db.Apps.FirstOrDefaultAsync(a => a.Name == appName, ct)
            ?? throw new KeyNotFoundException($"App '{appName}' not found");

        // Resolve the app's GitHub source to the org + host the agent must clone from.
        var src = sources.Resolve(entity.GithubSource);
        var githubHost = new Uri(src.ApiBase).Host is var h && h.Equals("api.github.com", StringComparison.OrdinalIgnoreCase)
            ? "github.com"
            : h;

        var result = await ado.TriggerOrchestratorAsync(
            entity.GithubRepo, branch, environment, config.TrimStart('/'),
            review, build, tests, scan, deploy, integrations, deployInfra, forceStateCopy, CurrentUserDisplayName,
            src.Org, githubHost, ct);

        audit.Record("pipeline.trigger_run", $"app:{appName};run:{result.RunId}",
            detail: $"branch={branch};env={environment};config={config}");

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

        audit.Record("pipeline.cancel_run", $"app:{appName};run:{runId}",
            detail: $"builds={string.Join(',', buildIds)}");

        // Update local DB record if we have it (match on either build id of the pair)
        var run = await db.Set<PipelineRunEntity>()
            .FirstOrDefaultAsync(r => buildIds.Contains(r.Id) && r.AppId == entity.Id, ct);
        if (run is not null)
        {
            run.Status = "Canceled";
            await db.SaveChangesAsync(ct);
        }
    }

    public async Task<List<string>> FindConfigsAsync(string repo, string branch, string? source = null, CancellationToken ct = default)
    {
        return await gitHub.FindEpicConfigsAsync(repo, branch, source, ct);
    }

    public async Task<ConfigCheckResult> CheckConfigInfraAsync(string repo, string branch, string configPath, string? source = null, CancellationToken ct = default)
    {
        return await gitHub.CheckInfraAsync(repo, branch, configPath, source, ct);
    }

    // ----- Mapping helpers -----

    private ManagedApp ToManagedApp(AppEntity entity, (int Total, int Successful, TimeSpan TotalDuration) stats, (string? Cloud, string? Environment, string? AppType, string? AppName) lastRunTags = default)
    {
        var lastRun = entity.Runs.MaxBy(r => r.StartedAt);

        return new ManagedApp
        {
            Name = entity.Name,
            AppName = lastRunTags.AppName,
            Technology = lastRun is not null ? ResolveTechnology(lastRunTags.AppType, entity.Technology) : "-",
            GithubOrg = ResolveGithubOrg(entity.GithubSource),
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

    // Resolves the app's stored source name to its GitHub org for display.
    // Falls back gracefully if the source is unknown/misconfigured so a bad
    // config never breaks the app list.
    private string? ResolveGithubOrg(string source)
    {
        try { return sources.Resolve(source).Org; }
        catch (UnknownGitHubSourceException) { return null; }
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
            Branch = entity.GithubBranch,
            Source = entity.GithubSource
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
