using Epic.Api.Auth;
using Epic.Api.Data;
using Epic.Api.Data.Entities;
using Epic.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Epic.Api.Services;

public sealed class AppService(EpicDbContext db, IGitHubService gitHub, IAdoService ado, ICurrentUser currentUser) : IAppService
{
    private string CurrentUserId => currentUser.UserId;

    public async Task<List<ManagedApp>> GetUserAppsAsync(CancellationToken ct = default)
    {
        return await db.UserApps
            .Where(ua => ua.UserId == CurrentUserId)
            .Include(ua => ua.App)
                .ThenInclude(a => a.Runs.OrderByDescending(r => r.StartedAt).Take(1))
            .Select(ua => ToManagedApp(ua.App))
            .ToListAsync(ct);
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

    private async Task RefreshFromGitHubAsync(AppEntity entity, CancellationToken ct)
    {
        try
        {
            var repoInfo = await gitHub.GetRepoAsync(entity.GithubRepo, ct);
            if (!repoInfo.Exists) return;

            var technology = MapLanguageToTechnology(repoInfo.Language);
            var appType = MapTechnologyToAppType(technology);
            var hasChanges = false;

            if (entity.Technology != technology)
            {
                entity.Technology = technology;
                entity.AppType = appType;
                hasChanges = true;
            }

            if (repoInfo.Description is not null && entity.Description != repoInfo.Description)
            {
                entity.Description = repoInfo.Description;
                hasChanges = true;
            }

            if (hasChanges)
            {
                entity.LastUpdatedAt = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
            }
        }
        catch
        {
            // GitHub is unavailable — serve stale data rather than failing
        }
    }

    private async Task RefreshRunsFromAdoAsync(AppEntity entity, CancellationToken ct)
    {
        try
        {
            var adoRuns = await ado.GetRunsForAppAsync(entity.Name, 20, ct);
            if (adoRuns.Count == 0) return;

            // Get existing run IDs to avoid duplicates
            var existingRunIds = entity.Runs.Select(r => r.Id).ToHashSet();

            var hasChanges = false;

            foreach (var run in adoRuns)
            {
                if (existingRunIds.Contains(run.Id))
                {
                    // Update existing run (status may have changed if it was Running)
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
                        hasChanges = true;
                    }
                }
                else
                {
                    // New run from ADO — add to DB
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
                        StageAppDeploy = run.Stages.AppDeploy.ToString()
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
        catch
        {
            // ADO is unavailable — serve stale data rather than failing
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
        var app = await db.Apps.FirstOrDefaultAsync(a => a.Name == name, ct)
            ?? throw new KeyNotFoundException($"App '{name}' not found");

        db.UserApps.Add(new UserAppEntity
        {
            UserId = CurrentUserId,
            AppId = app.Id
        });

        await db.SaveChangesAsync(ct);

        return ToManagedApp(app);
    }

    public async Task<AppDetail> OnboardAppAsync(string repo, string branch, CancellationToken ct = default)
    {
        var repoInfo = await gitHub.GetRepoAsync(repo, ct);
        if (!repoInfo.Exists)
            throw new KeyNotFoundException($"GitHub repo '{repo}' not found");

        var technology = MapLanguageToTechnology(repoInfo.Language);
        var appType = MapTechnologyToAppType(technology);

        var entity = new AppEntity
        {
            Name = repo.ToLowerInvariant(),
            DisplayName = FormatDisplayName(repo),
            Description = repoInfo.Description,
            AppType = appType,
            Technology = technology,
            Cloud = "aws",
            Environment = "dev",
            Team = "unassigned",
            Domain = "",
            GithubRepo = repo,
            GithubBranch = branch.Length > 0 ? branch : repoInfo.DefaultBranch ?? "main",
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

    private static string FormatDisplayName(string repo) =>
        string.Join(' ', repo.Split('-', '_')
            .Select(w => w.Length > 0 ? char.ToUpper(w[0]) + w[1..] : w));

    public Task<PipelineRun> TriggerRunAsync(string appName, string branch, string environment, CancellationToken ct = default)
    {
        // TODO: Call ADO REST API to trigger the EPIC orchestrator pipeline
        // POST https://dev.azure.com/pgetech/EPIC-Pipeline/_apis/pipelines/194/runs
        throw new NotImplementedException("ADO REST API integration not yet implemented");
    }

    // ----- Mapping helpers -----

    private static ManagedApp ToManagedApp(AppEntity entity)
    {
        var lastRun = entity.Runs.MaxBy(r => r.StartedAt);

        return new ManagedApp
        {
            Name = entity.Name,
            Technology = entity.Technology,
            Cloud = entity.Cloud,
            Environment = entity.Environment,
            LastPipelineRun = lastRun?.StartedAt.ToString("o"),
            RunStatus = lastRun is not null ? Enum.Parse<RunStatus>(lastRun.Status, true) : null,
            TriggeredBy = lastRun?.TriggeredBy
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
                AppDeploy = Enum.Parse<RunStatus>(r.StageAppDeploy, true)
            }
        }).ToList()
    };
}
