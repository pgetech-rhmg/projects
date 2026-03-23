using Epic.Api.Auth;
using Epic.Api.Data;
using Epic.Api.Data.Entities;
using Epic.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Epic.Api.Services;

public sealed class AppService(EpicDbContext db, IGitHubService gitHub, ICurrentUser currentUser) : IAppService
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

        return ToAppDetail(entity);
    }

    public async Task<RepoCheckResult> CheckRepoAsync(string repo, CancellationToken ct = default)
    {
        var app = await db.Apps.FirstOrDefaultAsync(a => a.GithubRepo == repo, ct);

        if (app is null)
        {
            var repoExists = await gitHub.RepoExistsAsync(repo, ct);
            return new RepoCheckResult
            {
                Status = repoExists ? "available" : "not-found"
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
        var entity = new AppEntity
        {
            Name = repo.ToLowerInvariant().Replace("/", "-"),
            DisplayName = repo,
            AppType = "unknown",
            Technology = "unknown",
            Cloud = "aws",
            Environment = "dev",
            Team = "unassigned",
            Domain = "",
            GithubRepo = repo,
            GithubBranch = branch,
            CreatedBy = CurrentUserId,
            LastUpdatedBy = CurrentUserId
        };

        db.Apps.Add(entity);

        // Auto-track for the onboarding user
        db.UserApps.Add(new UserAppEntity
        {
            UserId = CurrentUserId,
            App = entity
        });

        await db.SaveChangesAsync(ct);

        return ToAppDetail(entity);
    }

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
