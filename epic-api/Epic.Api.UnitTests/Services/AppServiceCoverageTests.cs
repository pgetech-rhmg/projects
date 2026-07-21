using Epic.Api.Data.Entities;
using Epic.Api.Services;
using Epic.Api.UnitTests.TestHelpers;
using Moq;
using Xunit;

namespace Epic.Api.UnitTests.Services;

/// <summary>
/// Branch-completion tests for AppService's mapping switches (language→tech,
/// tech→appType, appType→tech, cloud casing) and the Azure config projection.
/// </summary>
public sealed class AppServiceCoverageTests
{
    private readonly Mock<IGitHubService> _gitHub = new();
    private readonly Mock<IAdoService> _ado = new();

    private static readonly IGitHubSourceRegistry Sources =
        new GitHubSourceRegistry(TestData.Config(("GITHUB_BASE_URL", "https://github.com/pgetech"), ("GITHUB_TOKEN", "tok")));

    private AppService Make(Epic.Api.Data.EpicDbContext db) =>
        new(db, _gitHub.Object, Sources, _ado.Object, new StubCurrentUser(), new RecordingAuditLog(), TestData.Logger<AppService>());

    private void NoRuns()
    {
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync([]);
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync((0, 0, TimeSpan.Zero));
    }

    // Onboard maps repo primary language → appType. Sweep the language arms.
    [Theory]
    [InlineData("Python", "python")]
    [InlineData("Java", "java")]
    [InlineData("Kotlin", "java")]
    [InlineData("HCL", "hcl")]
    [InlineData("Go", "unknown")]       // language→"Go" tech, but MapTechnologyToAppType has no Go arm
    [InlineData("HTML", "html")]
    [InlineData("TypeScript", "angular")]  // typescript/javascript → Angular → angular
    [InlineData("JavaScript", "angular")]
    [InlineData("C#", "dotnet")]
    [InlineData("Shell", "unknown")]        // shell → "Shell" tech, no appType arm
    [InlineData("CSS", "html")]             // css → HTML → html
    [InlineData("Ruby", "unknown")]         // Ruby → "Ruby" tech, no appType arm → unknown
    [InlineData("Rust", "unknown")]         // unmapped language passthrough → unknown appType
    public async Task Onboard_MapsLanguageToAppType(string language, string expectedAppType)
    {
        using var db = TestData.NewDb();
        _gitHub.Setup(g => g.GetRepoAsync("r", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = true, Language = language, DefaultBranch = "main" });
        _gitHub.Setup(g => g.PathExistsAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>())).ReturnsAsync(false);
        NoRuns();

        var detail = await Make(db).OnboardAppAsync("r");
        Assert.Equal(expectedAppType, detail.AppType);
    }

    // MapAppTypeToTechnology arms, reached via GetApp's latest-run appType tag.
    [Theory]
    [InlineData("react", "React")]
    [InlineData("dotnet_framework", ".NET")]
    [InlineData("go", "Go")]
    [InlineData("html", "HTML")]
    [InlineData("hcl", "Terraform")]
    [InlineData("ami", "AMI")]
    [InlineData("btp", "SAP BTP")]
    [InlineData("cap", "SAP CAP")]
    [InlineData("infra", "Terraform")]
    [InlineData("mystery", "mystery")]  // default passthrough
    public async Task GetApp_MapsAppTypeToTechnology(string appType, string expectedTech)
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("app", id: 1));
        await db.SaveChangesAsync();
        _gitHub.Setup(g => g.GetRepoAsync(It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>())).ReturnsAsync(new GitHubRepoInfo { Exists = false });
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync((0, 0, TimeSpan.Zero));
        _ado.Setup(a => a.GetRecentRunsForAppAsync("app", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync([new AdoLatestRun { Id = 1, Status = "Success", TriggeredBy = "x", Branch = "main", Environment = "dev", AppType = appType, StartedAt = DateTime.UtcNow }]);

        var detail = await Make(db).GetAppAsync("app");
        Assert.Equal(expectedTech, detail!.Technology);
    }

    // Contract-less run (empty appType tag): Technology falls back to the
    // GitHub-derived value stored on the entity, and only to [UNKNOWN] when
    // that's blank too. Never a "-" (a run exists) and never an empty cell.
    [Theory]
    [InlineData("", "Angular", "Angular")]        // empty tag → GitHub fallback
    [InlineData("   ", "Angular", "Angular")]     // whitespace tag → GitHub fallback
    [InlineData("", "", "[UNKNOWN]")]             // no tag AND no GitHub tech → [UNKNOWN]
    [InlineData("react", "Angular", "React")]     // real tag wins over the fallback
    public async Task GetApp_ContractlessTechnologyFallsBackToGitHub(string appType, string entityTech, string expectedTech)
    {
        using var db = TestData.NewDb();
        var app = TestData.NewApp("app", id: 1);
        app.Technology = entityTech;
        db.Apps.Add(app);
        await db.SaveChangesAsync();
        // GitHub returns no language so RefreshFromGitHub leaves entity.Technology as seeded.
        _gitHub.Setup(g => g.GetRepoAsync(It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>())).ReturnsAsync(new GitHubRepoInfo { Exists = false });
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync((0, 0, TimeSpan.Zero));
        _ado.Setup(a => a.GetRecentRunsForAppAsync("app", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync([new AdoLatestRun { Id = 1, Status = "Success", TriggeredBy = "x", Branch = "main", Environment = "dev", AppType = appType, StartedAt = DateTime.UtcNow }]);

        var detail = await Make(db).GetAppAsync("app");
        Assert.Equal(expectedTech, detail!.Technology);
    }

    // MapCloud arms via ManagedApp (GetUserApps latest-run cloud tag).
    [Theory]
    [InlineData("btp", "SAP")]
    [InlineData("sap", "SAP")]
    [InlineData("weird", "weird")]   // default passthrough
    public async Task GetUserApps_MapsCloud(string cloud, string expected)
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("app", id: 1));
        db.UserApps.Add(new UserAppEntity { UserId = "rhmg", AppId = 1 });
        await db.SaveChangesAsync();
        _ado.Setup(a => a.GetRecentRunsForAppAsync("app", It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync([new AdoLatestRun { Id = 1, Status = "Success", TriggeredBy = "x", Branch = "main", Environment = "dev", Cloud = cloud, AppType = "angular", AppName = "app", StartedAt = DateTime.UtcNow }]);
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync((0, 0, TimeSpan.Zero));

        var apps = await Make(db).GetUserAppsAsync();
        Assert.Equal(expected, apps.Single().Cloud);
    }

    // AppDetail Azure projection (only AWS was covered elsewhere).
    [Fact]
    public async Task GetApp_ProjectsAzureConfig()
    {
        using var db = TestData.NewDb();
        var app = TestData.NewApp("app", id: 1);
        app.AzureSubscription = "sub-123";
        app.AzureResourceGroup = "rg-1";
        db.Apps.Add(app);
        await db.SaveChangesAsync();
        _gitHub.Setup(g => g.GetRepoAsync(It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>())).ReturnsAsync(new GitHubRepoInfo { Exists = false });
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync((0, 0, TimeSpan.Zero));
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync([]);

        var detail = await Make(db).GetAppAsync("app");
        Assert.NotNull(detail!.Azure);
        Assert.Equal("sub-123", detail.Azure!.Subscription);
        Assert.Equal("rg-1", detail.Azure.ResourceGroup);
    }

    // AppDetail AWS projection with all optional fields set.
    [Fact]
    public async Task GetApp_ProjectsAwsConfig()
    {
        using var db = TestData.NewDb();
        var app = TestData.NewApp("app", id: 1);
        app.AwsAccountId = "111"; app.AwsS3 = "bucket"; app.AwsCloudfront = "dist"; app.AwsEc2InstanceId = "i-1";
        db.Apps.Add(app);
        await db.SaveChangesAsync();
        _gitHub.Setup(g => g.GetRepoAsync(It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>())).ReturnsAsync(new GitHubRepoInfo { Exists = false });
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync((0, 0, TimeSpan.Zero));
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync([]);

        var detail = await Make(db).GetAppAsync("app");
        Assert.Equal("111", detail!.Aws!.AccountId);
        Assert.Equal("bucket", detail.Aws.S3);
    }

    // CheckRepo: repo not in DB and GitHub says it exists → "available";
    // RefreshFromGitHub swallow path when GitHub throws during GetApp.
    [Fact]
    public async Task GetApp_GitHubThrows_ServesStale()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("app", id: 1));
        await db.SaveChangesAsync();
        _gitHub.Setup(g => g.GetRepoAsync(It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new HttpRequestException("gh down"));
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync((0, 0, TimeSpan.Zero));
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync([]);

        var detail = await Make(db).GetAppAsync("app");
        Assert.NotNull(detail); // stale served, no throw
    }

    // FormatDuration arms: hours (≥1h), and sub-minute (seconds only).
    [Theory]
    [InlineData(3, "1h 30m")]    // 3h / 2 runs = 1h30m
    [InlineData(0, "45s")]        // sub-minute uses the seconds-only arm
    public async Task GetUserApps_AvgDurationArms(int hours, string expected)
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("app", id: 1));
        db.UserApps.Add(new UserAppEntity { UserId = "rhmg", AppId = 1 });
        await db.SaveChangesAsync();
        _ado.Setup(a => a.GetRecentRunsForAppAsync("app", It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync([new AdoLatestRun { Id = 1, Status = "Success", TriggeredBy = "x", Branch = "main", Environment = "dev", AppType = "angular", StartedAt = DateTime.UtcNow }]);
        var total = hours > 0 ? TimeSpan.FromHours(hours) : TimeSpan.FromSeconds(90); // /2 → 45s
        _ado.Setup(a => a.GetCompletedRunCountsAsync("app", It.IsAny<CancellationToken>()))
            .ReturnsAsync((2, 2, total));

        var apps = await Make(db).GetUserAppsAsync();
        Assert.Equal(expected, apps.Single().AvgDuration);
    }
}
