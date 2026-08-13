using Epic.Api.Data;
using Epic.Api.Data.Entities;
using Epic.Api.Models;
using Epic.Api.Services;
using Epic.Api.UnitTests.TestHelpers;
using Moq;
using Xunit;

namespace Epic.Api.UnitTests.Services;

public sealed class AppServiceTests
{
    private readonly Mock<IGitHubService> _gitHub = new();
    private readonly Mock<IAdoService> _ado = new();
    private readonly StubCurrentUser _user = new();
    private readonly RecordingAuditLog _audit = new();

    private static readonly IGitHubSourceRegistry Sources =
        new GitHubSourceRegistry(TestData.Config(("GITHUB_BASE_URL", "https://github.com/pgetech"), ("GITHUB_TOKEN", "tok")));

    private AppService Make(EpicDbContext db) =>
        new(db, _gitHub.Object, Sources, _ado.Object, _user, _audit, TestData.Logger<AppService>());

    private static (int Total, int Successful, TimeSpan TotalDuration) Stats(int total, int ok, TimeSpan dur) => (total, ok, dur);

    // ---- GetUserAppsAsync ----

    [Fact]
    public async Task GetUserApps_ReturnsAppsWithStatsAndTags()
    {
        using var db = TestData.NewDb();
        var app = TestData.NewApp("epic-web", id: 1);
        db.Apps.Add(app);
        db.UserApps.Add(new UserAppEntity { UserId = "rhmg", AppId = 1 });
        db.PipelineRuns.Add(TestData.NewRun(10, 1, "Success"));
        await db.SaveChangesAsync();

        _ado.Setup(a => a.GetRecentRunsForAppAsync("epic-web", It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync([new AdoLatestRun { Id = 10, Status = "Success", TriggeredBy = "Morgan, Robb", Branch = "main", Environment = "prod", Cloud = "aws", AppType = "angular", AppName = "epic-web", StartedAt = DateTime.UtcNow }]);
        _ado.Setup(a => a.GetCompletedRunCountsAsync("epic-web", It.IsAny<CancellationToken>()))
            .ReturnsAsync(Stats(4, 3, TimeSpan.FromMinutes(8)));

        var apps = await Make(db).GetUserAppsAsync();

        var m = Assert.Single(apps);
        Assert.Equal("epic-web", m.Name);
        Assert.Equal("Angular", m.Technology);   // mapped from appType
        Assert.Equal("pgetech", m.GithubOrg);    // resolved from the app's source ("default" → pgetech)
        Assert.Equal("AWS", m.Cloud);
        Assert.Equal("prod", m.Environment);
        Assert.Equal(75, m.SuccessRate);          // 3/4
        Assert.Equal("2m 0s", m.AvgDuration);     // 8m / 4 (Seconds not zero-padded here)
    }

    [Fact]
    public async Task GetUserApps_AdoUnavailable_ServesStaleWithDashes()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        db.UserApps.Add(new UserAppEntity { UserId = "rhmg", AppId = 1 });
        await db.SaveChangesAsync();

        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new HttpRequestException("ADO down"));
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new HttpRequestException("ADO down"));

        var apps = await Make(db).GetUserAppsAsync();

        var m = Assert.Single(apps);
        Assert.Equal("-", m.Technology);
        Assert.Null(m.SuccessRate);
    }

    // ---- GetAppAsync ----

    [Fact]
    public async Task GetApp_NotFound_ReturnsNull()
    {
        using var db = TestData.NewDb();
        Assert.Null(await Make(db).GetAppAsync("missing"));
    }

    [Fact]
    public async Task GetApp_RefreshesFromGitHub_AndComputesStats()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        await db.SaveChangesAsync();

        _gitHub.Setup(g => g.GetRepoAsync("epic-web", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = true, Description = "new desc" });
        _gitHub.Setup(g => g.PathExistsAsync("epic-web", ".infra", "main", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);
        _ado.Setup(a => a.GetCompletedRunCountsAsync("epic-web", It.IsAny<CancellationToken>()))
            .ReturnsAsync(Stats(2, 1, TimeSpan.FromMinutes(4)));
        _ado.Setup(a => a.GetRecentRunsForAppAsync("epic-web", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync([new AdoLatestRun { Id = 5, Status = "Success", TriggeredBy = "x", Branch = "main", Environment = "dev", Cloud = "azure", AppType = "dotnet", StartedAt = DateTime.UtcNow }]);

        var detail = await Make(db).GetAppAsync("epic-web");

        Assert.NotNull(detail);
        Assert.Equal(".NET", detail!.Technology);
        Assert.Equal("Azure", detail.Cloud);
        Assert.Equal(50, detail.SuccessRate);
        Assert.True(detail.HasInfra);
        Assert.Equal("new desc", detail.Description);
    }

    [Fact]
    public async Task GetApp_RefreshSyncsTechnologyFromGitHubLanguage()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));  // seeded Technology = "Angular"
        await db.SaveChangesAsync();

        // GitHub now reports Python; the entity's fallback Technology should update.
        _gitHub.Setup(g => g.GetRepoAsync("epic-web", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = true, Language = "Python" });
        _gitHub.Setup(g => g.PathExistsAsync("epic-web", ".infra", "main", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(false);
        _ado.Setup(a => a.GetCompletedRunCountsAsync("epic-web", It.IsAny<CancellationToken>()))
            .ReturnsAsync(Stats(0, 0, TimeSpan.Zero));
        // Contract-less run: empty appType tag → Technology falls back to the synced language.
        _ado.Setup(a => a.GetRecentRunsForAppAsync("epic-web", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync([new AdoLatestRun { Id = 7, Status = "Success", TriggeredBy = "x", Branch = "main", Environment = "dev", AppType = "", StartedAt = DateTime.UtcNow }]);

        var detail = await Make(db).GetAppAsync("epic-web");

        Assert.Equal("Python", detail!.Technology);
        Assert.Equal("Python", (await db.Apps.FindAsync(1))!.Technology);
    }

    [Fact]
    public async Task GetApp_NoRuns_TechnologyAndCloudDash()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        await db.SaveChangesAsync();

        _gitHub.Setup(g => g.GetRepoAsync(It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = false });
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Stats(0, 0, TimeSpan.Zero));
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync([]);

        var detail = await Make(db).GetAppAsync("epic-web");
        Assert.Equal("-", detail!.Technology);
        Assert.Equal("-", detail.Cloud);
        Assert.Null(detail.SuccessRate);
    }

    [Fact]
    public async Task GetApp_AdoUnavailable_ServesStaleData_NoThrow()
    {
        // ADO down must not 500 the app detail (which the browser would report as
        // a phantom CORS error) — serve the stored technology instead.
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        await db.SaveChangesAsync();

        _gitHub.Setup(g => g.GetRepoAsync(It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = false });
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Stats(0, 0, TimeSpan.Zero));
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new HttpRequestException("ADO down"));

        var detail = await Make(db).GetAppAsync("epic-web");   // must not throw
        Assert.NotNull(detail);
        Assert.Equal("-", detail!.Technology);   // no latest run → dash, stale-safe
    }

    // ---- GetRunsPageAsync ----

    [Fact]
    public async Task GetRunsPage_NotFound_ReturnsNull()
    {
        using var db = TestData.NewDb();
        Assert.Null(await Make(db).GetRunsPageAsync("missing", 1, 20));
    }

    [Fact]
    public async Task GetRunsPage_MapsAdoPage()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        await db.SaveChangesAsync();

        _ado.Setup(a => a.GetRunsPageAsync("epic-web", 1, 20, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new AdoRunsPage
            {
                Total = 1,
                Runs = [new AdoPipelineRun { Id = 7, Status = "Success", TriggeredBy = "x", Branch = "main", Environment = "dev", Cloud = "aws", StartedAt = DateTime.UtcNow, Stages = new PipelineStages() }]
            });

        var page = await Make(db).GetRunsPageAsync("epic-web", 1, 20);
        Assert.Equal(1, page!.Total);
        Assert.Equal("AWS", page.Runs[0].Cloud);
        Assert.Equal(RunStatus.Success, page.Runs[0].Status);
    }

    [Fact]
    public async Task GetRunsPage_AdoThrows_ReturnsEmptyPage()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        await db.SaveChangesAsync();

        _ado.Setup(a => a.GetRunsPageAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new HttpRequestException("down"));

        var page = await Make(db).GetRunsPageAsync("epic-web", 2, 20);
        Assert.Equal(0, page!.Total);
        Assert.Empty(page.Runs);
    }

    // ---- Stage detail / logs / compliance passthroughs ----

    [Fact]
    public async Task GetStageDetail_NullWhenAppMissing_DelegatesWhenPresent()
    {
        using var db = TestData.NewDb();
        Assert.Null(await Make(db).GetStageDetailAsync("missing", 1, "build"));

        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        await db.SaveChangesAsync();
        _ado.Setup(a => a.GetStageDetailAsync(1, "build", It.IsAny<CancellationToken>()))
            .ReturnsAsync(new StageDetail { StageName = "build", Jobs = [] });

        var detail = await Make(db).GetStageDetailAsync("epic-web", 1, "build");
        Assert.Equal("build", detail!.StageName);
    }

    [Fact]
    public async Task GetStepLog_And_Compliance_Passthroughs()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        await db.SaveChangesAsync();
        var svc = Make(db);

        _ado.Setup(a => a.GetStepLogAsync(1, 2, It.IsAny<CancellationToken>())).ReturnsAsync("log");
        _ado.Setup(a => a.GetScanResultUrlAsync(1, It.IsAny<CancellationToken>())).ReturnsAsync("https://sonarqube/dashboard?id=x");
        _ado.Setup(a => a.GetComplianceReportAsync(1, It.IsAny<CancellationToken>())).ReturnsAsync("# md");
        _ado.Setup(a => a.GetComplianceSummaryAsync(1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ComplianceSummary { ByVerdict = new() });
        _ado.Setup(a => a.GetComplianceReportJsonAsync(1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ComplianceReport { Summary = new ComplianceSummary { ByVerdict = new() }, Findings = [] });

        Assert.Equal("log", await svc.GetStepLogAsync("epic-web", 1, 2));
        Assert.Equal("https://sonarqube/dashboard?id=x", await svc.GetScanResultUrlAsync("epic-web", 1));
        Assert.Equal("# md", await svc.GetComplianceReportAsync("epic-web", 1));
        Assert.NotNull(await svc.GetComplianceSummaryAsync("epic-web", 1));
        Assert.NotNull(await svc.GetComplianceReportJsonAsync("epic-web", 1));
    }

    [Fact]
    public async Task Compliance_And_Log_ReturnNull_WhenAppMissing()
    {
        using var db = TestData.NewDb();
        var svc = Make(db);
        Assert.Null(await svc.GetStepLogAsync("missing", 1, 2));
        Assert.Null(await svc.GetScanResultUrlAsync("missing", 1));
        Assert.Null(await svc.GetComplianceReportAsync("missing", 1));
        Assert.Null(await svc.GetComplianceSummaryAsync("missing", 1));
        Assert.Null(await svc.GetComplianceReportJsonAsync("missing", 1));
    }

    // ---- CheckRepoAsync ----

    [Fact]
    public async Task CheckRepo_UnknownRepo_AvailableOrNotFound()
    {
        using var db = TestData.NewDb();
        _gitHub.Setup(g => g.GetRepoAsync("new-repo", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = true });
        Assert.Equal("available", (await Make(db).CheckRepoAsync("new-repo")).Status);

        _gitHub.Setup(g => g.GetRepoAsync("ghost", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = false });
        Assert.Equal("not-found", (await Make(db).CheckRepoAsync("ghost")).Status);
    }

    [Fact]
    public async Task CheckRepo_TrackedByUser_AlreadyMine_ElseInEpicNotMine()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", repo: "epic-web", id: 1));
        db.UserApps.Add(new UserAppEntity { UserId = "rhmg", AppId = 1 });
        await db.SaveChangesAsync();

        var mine = await Make(db).CheckRepoAsync("epic-web");
        Assert.Equal("already-mine", mine.Status);
        Assert.NotNull(mine.MasterApp);

        // A different user's DB: app exists but not tracked by rhmg
        using var db2 = TestData.NewDb();
        db2.Apps.Add(TestData.NewApp("epic-api", repo: "epic-api", id: 2));
        await db2.SaveChangesAsync();
        var notMine = await Make(db2).CheckRepoAsync("epic-api");
        Assert.Equal("in-epic-not-mine", notMine.Status);
    }

    // ---- AddToMyAppsAsync ----

    [Fact]
    public async Task AddToMyApps_AddsRow_AndAudits()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        await db.SaveChangesAsync();
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync([]);
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync(Stats(0, 0, TimeSpan.Zero));

        var result = await Make(db).AddToMyAppsAsync("epic-web");

        Assert.Equal("epic-web", result.Name);
        Assert.True(db.UserApps.Any(ua => ua.UserId == "rhmg" && ua.AppId == 1));
        Assert.Contains(_audit.Records, r => r.EventType == "app.add_to_my_apps");
    }

    [Fact]
    public async Task AddToMyApps_MissingApp_Throws()
    {
        using var db = TestData.NewDb();
        await Assert.ThrowsAsync<KeyNotFoundException>(() => Make(db).AddToMyAppsAsync("missing"));
    }

    [Fact]
    public async Task AddToMyApps_AlreadyInPortfolio_IsNoOp_NoDuplicateJoin()
    {
        // Re-adding an app already in the portfolio must not violate the
        // (UserId, AppId) unique index (would be an unhandled 500 / phantom CORS).
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        db.UserApps.Add(new UserAppEntity { UserId = "rhmg", AppId = 1 });
        await db.SaveChangesAsync();
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync([]);
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync(Stats(0, 0, TimeSpan.Zero));

        var result = await Make(db).AddToMyAppsAsync("epic-web");   // must not throw

        Assert.Equal("epic-web", result.Name);
        Assert.Equal(1, db.UserApps.Count(ua => ua.UserId == "rhmg" && ua.AppId == 1));
    }

    // ---- OnboardAppAsync ----

    [Fact]
    public async Task OnboardApp_CreatesAppAndUserApp_AndAudits()
    {
        using var db = TestData.NewDb();
        _gitHub.Setup(g => g.GetRepoAsync("New-Repo", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = true, Language = "C#", DefaultBranch = "develop", Description = "d" });
        _gitHub.Setup(g => g.PathExistsAsync("New-Repo", ".infra", "develop", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync([]);

        var detail = await Make(db).OnboardAppAsync("New-Repo");

        Assert.Equal("new-repo", detail.Name);          // lowercased
        Assert.Equal("New Repo", detail.DisplayName);   // formatted
        Assert.Equal("dotnet", detail.AppType);         // C# → dotnet
        Assert.Equal(".NET", detail.Technology);
        Assert.True(detail.HasInfra);
        Assert.True(db.UserApps.Any(ua => ua.UserId == "rhmg"));
        Assert.Contains(_audit.Records, r => r.EventType == "app.onboard");
    }

    [Fact]
    public async Task OnboardApp_RepoMissing_Throws()
    {
        using var db = TestData.NewDb();
        _gitHub.Setup(g => g.GetRepoAsync(It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = false });
        await Assert.ThrowsAsync<KeyNotFoundException>(() => Make(db).OnboardAppAsync("ghost"));
    }

    [Fact]
    public async Task OnboardApp_NullLanguageAndBranch_DefaultsApplied()
    {
        using var db = TestData.NewDb();
        _gitHub.Setup(g => g.GetRepoAsync("r", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = true, Language = null, DefaultBranch = null });
        _gitHub.Setup(g => g.PathExistsAsync("r", ".infra", "main", It.IsAny<string?>(), It.IsAny<CancellationToken>())).ReturnsAsync(false);
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync([]);

        var detail = await Make(db).OnboardAppAsync("r");
        Assert.Equal("unknown", detail.AppType);   // null language → Unknown → unknown
    }

    [Fact]
    public async Task OnboardApp_ReAddAfterRemove_ReusesCatalogEntry_NoDuplicate()
    {
        // Repro of the "remove from portfolio then add back" 500: the catalog row
        // survives removal, so a second onboard must reuse it (not insert a
        // duplicate that violates the Name / (GithubSource,GithubRepo) indexes).
        using var db = TestData.NewDb();
        _gitHub.Setup(g => g.GetRepoAsync("New-Repo", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = true, Language = "C#", DefaultBranch = "develop", Description = "d" });
        _gitHub.Setup(g => g.PathExistsAsync("New-Repo", ".infra", "develop", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync([]);

        await Make(db).OnboardAppAsync("New-Repo");
        await Make(db).RemoveFromMyAppsAsync("new-repo");
        var detail = await Make(db).OnboardAppAsync("New-Repo");   // must not throw

        Assert.Equal("new-repo", detail.Name);
        Assert.Equal(1, db.Apps.Count(a => a.Name == "new-repo"));   // still one catalog row
        Assert.Equal(1, db.UserApps.Count(ua => ua.UserId == "rhmg"));   // re-attached exactly once
    }

    [Fact]
    public async Task OnboardApp_AlreadyInPortfolio_IsNoOp_NoDuplicateJoin()
    {
        using var db = TestData.NewDb();
        _gitHub.Setup(g => g.GetRepoAsync("New-Repo", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GitHubRepoInfo { Exists = true, Language = "C#", DefaultBranch = "develop", Description = "d" });
        _gitHub.Setup(g => g.PathExistsAsync("New-Repo", ".infra", "develop", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);
        _ado.Setup(a => a.GetRecentRunsForAppAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>())).ReturnsAsync([]);

        await Make(db).OnboardAppAsync("New-Repo");
        await Make(db).OnboardAppAsync("New-Repo");   // onboard twice without removing

        Assert.Equal(1, db.Apps.Count(a => a.Name == "new-repo"));
        Assert.Equal(1, db.UserApps.Count(ua => ua.UserId == "rhmg"));
    }

    // ---- RemoveFromMyAppsAsync ----

    [Fact]
    public async Task RemoveFromMyApps_RemovesAndAudits()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        db.UserApps.Add(new UserAppEntity { UserId = "rhmg", AppId = 1 });
        await db.SaveChangesAsync();

        await Make(db).RemoveFromMyAppsAsync("epic-web");

        Assert.False(db.UserApps.Any());
        Assert.Contains(_audit.Records, r => r.EventType == "app.remove_from_my_apps");
    }

    [Fact]
    public async Task RemoveFromMyApps_AppMissing_Throws()
    {
        using var db = TestData.NewDb();
        await Assert.ThrowsAsync<KeyNotFoundException>(() => Make(db).RemoveFromMyAppsAsync("missing"));
    }

    [Fact]
    public async Task RemoveFromMyApps_NotTracked_Throws()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        await db.SaveChangesAsync();
        await Assert.ThrowsAsync<KeyNotFoundException>(() => Make(db).RemoveFromMyAppsAsync("epic-web"));
    }

    // ---- TriggerRunAsync ----

    [Fact]
    public async Task TriggerRun_DelegatesToAdo_AndAudits()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", repo: "epic-web", id: 1));
        await db.SaveChangesAsync();
        _ado.Setup(a => a.TriggerOrchestratorAsync("epic-web", "main", "dev", "epic.json",
                true, true, false, false, false, false, "none", false, "Morgan, Robb",
                It.IsAny<string>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new AdoTriggerResult { RunId = 99, Url = "u" });

        var result = await Make(db).TriggerRunAsync("epic-web", "main", "dev", "/epic.json",
            true, true, false, false, false, false, "none", false);

        Assert.Equal(99, result.RunId);
        Assert.Contains(_audit.Records, r => r.EventType == "pipeline.trigger_run");
    }

    [Fact]
    public async Task TriggerRun_AppMissing_Throws()
    {
        using var db = TestData.NewDb();
        await Assert.ThrowsAsync<KeyNotFoundException>(() => Make(db).TriggerRunAsync(
            "missing", "main", "dev", "epic.json", true, true, false, false, false, false, "none", false));
    }

    // ---- CancelRunAsync ----

    [Fact]
    public async Task CancelRun_ResolvesPair_CancelsBoth_UpdatesLocalRecord()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", repo: "epic-web", id: 1));
        db.PipelineRuns.Add(TestData.NewRun(200, 1, "Running"));
        await db.SaveChangesAsync();

        _ado.Setup(a => a.GetRunsPageAsync("epic-web", 1, 50, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new AdoRunsPage
            {
                Total = 1,
                Runs = [new AdoPipelineRun { Id = 200, OrchestratorId = 199, Status = "Running", TriggeredBy = "x", Branch = "main", Environment = "dev", StartedAt = DateTime.UtcNow, Stages = new PipelineStages() }]
            });
        _ado.Setup(a => a.CancelBuildAsync(It.IsAny<int>(), It.IsAny<CancellationToken>())).Returns(Task.CompletedTask);

        await Make(db).CancelRunAsync("epic-web", 200);

        _ado.Verify(a => a.CancelBuildAsync(200, It.IsAny<CancellationToken>()), Times.Once);
        _ado.Verify(a => a.CancelBuildAsync(199, It.IsAny<CancellationToken>()), Times.Once);
        Assert.Equal("Canceled", db.PipelineRuns.Single().Status);
        Assert.Contains(_audit.Records, r => r.EventType == "pipeline.cancel_run");
    }

    [Fact]
    public async Task CancelRun_AdoResolveFails_CancelsGivenIdOnly()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", repo: "epic-web", id: 1));
        await db.SaveChangesAsync();

        _ado.Setup(a => a.GetRunsPageAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new HttpRequestException("down"));
        _ado.Setup(a => a.CancelBuildAsync(It.IsAny<int>(), It.IsAny<CancellationToken>())).Returns(Task.CompletedTask);

        await Make(db).CancelRunAsync("epic-web", 200);
        _ado.Verify(a => a.CancelBuildAsync(200, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task CancelRun_AppMissing_Throws()
    {
        using var db = TestData.NewDb();
        await Assert.ThrowsAsync<KeyNotFoundException>(() => Make(db).CancelRunAsync("missing", 1));
    }

    // ---- FindConfigs / CheckConfigInfra passthroughs ----

    [Fact]
    public async Task FindConfigs_And_CheckConfigInfra_Delegate()
    {
        using var db = TestData.NewDb();
        _gitHub.Setup(g => g.FindEpicConfigsAsync("r", "main", It.IsAny<string?>(), It.IsAny<CancellationToken>())).ReturnsAsync(["epic.json"]);
        _gitHub.Setup(g => g.CheckInfraAsync("r", "main", "epic.json", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ConfigCheckResult { HasInfra = true, AppType = "dotnet" });

        Assert.Equal(["epic.json"], await Make(db).FindConfigsAsync("r", "main"));
        var check = await Make(db).CheckConfigInfraAsync("r", "main", "epic.json");
        Assert.True(check.HasInfra);
        Assert.Equal("dotnet", check.AppType);
    }

    // ---- RefreshRecentRuns: new-run insert + status update ----

    [Fact]
    public async Task GetUserApps_ReconcilesExistingRun_AndAttemptsNewRunInsert()
    {
        using var db = TestData.NewDb();
        db.Apps.Add(TestData.NewApp("epic-web", id: 1));
        db.UserApps.Add(new UserAppEntity { UserId = "rhmg", AppId = 1 });
        db.PipelineRuns.Add(TestData.NewRun(10, 1, "Running"));  // reconciled to Success
        await db.SaveChangesAsync();

        // Run 10 changed status (update branch) + run 11 is new (insert branch).
        _ado.Setup(a => a.GetRecentRunsForAppAsync("epic-web", It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(
            [
                new AdoLatestRun { Id = 10, Status = "Success", TriggeredBy = "Morgan, Robb", Branch = "main", Environment = "dev", Duration = "1m", StartedAt = DateTime.UtcNow },
                new AdoLatestRun { Id = 11, Status = "Success", TriggeredBy = "Morgan, Robb", Branch = "main", Environment = "dev", StartedAt = DateTime.UtcNow.AddMinutes(1) }
            ]);
        _ado.Setup(a => a.GetCompletedRunCountsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Stats(2, 2, TimeSpan.FromMinutes(2)));

        // Exercises both the update and new-run-insert branches. (The EF InMemory
        // provider can't persist an explicit-PK entity added to a tracked nav
        // collection, so the SaveChanges for the inserted row is swallowed by the
        // stale-data handler — the tracked update to run 10 is still observable.
        // Production keys runs by the ADO build id against Postgres and persists both.)
        await Make(db).GetUserAppsAsync();

        Assert.Equal("Success", db.PipelineRuns.Single(r => r.Id == 10).Status);
    }
}
