using Epic.Api.Controllers;
using Epic.Api.Models;
using Epic.Api.Services;
using Epic.Api.UnitTests.TestHelpers;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Xunit;

namespace Epic.Api.UnitTests.Controllers;

public sealed class AppsControllerTests
{
    private readonly Mock<IAppService> _svc = new();
    private readonly IGitHubSourceRegistry _sources =
        new GitHubSourceRegistry(TestData.Config(("GITHUB_BASE_URL", "https://github.com/pgetech"), ("GITHUB_TOKEN", "tok")));
    private AppsController Sut() => new(_svc.Object, _sources);

    private static AppDetail Detail(string name = "epic-web") => new()
    {
        Name = name, DisplayName = name, AppType = "angular", Technology = "Angular",
        Cloud = "AWS", Environment = "dev", Team = "t", LastUpdatedBy = "u", Domain = "",
        Github = new GitHubInfo { Repo = name }
    };

    // ---- GetApp ----

    [Fact]
    public async Task GetApp_Found_Ok()
    {
        _svc.Setup(s => s.GetAppAsync("epic-web", It.IsAny<CancellationToken>())).ReturnsAsync(Detail());
        var result = await Sut().GetApp("epic-web", default);
        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.IsType<AppDetail>(ok.Value);
    }

    [Fact]
    public async Task GetApp_Missing_NotFound()
    {
        _svc.Setup(s => s.GetAppAsync(It.IsAny<string>(), It.IsAny<CancellationToken>())).ReturnsAsync((AppDetail?)null);
        Assert.IsType<NotFoundResult>(await Sut().GetApp("x", default));
    }

    // ---- GetRuns ----

    [Fact]
    public async Task GetRuns_Found_Ok()
    {
        _svc.Setup(s => s.GetRunsPageAsync("epic-web", 1, 20, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PipelineRunPage { Total = 0, Page = 1, PageSize = 20, Runs = [] });
        Assert.IsType<OkObjectResult>(await Sut().GetRuns("epic-web", 1, 20, default));
    }

    [Fact]
    public async Task GetRuns_Missing_NotFound()
    {
        _svc.Setup(s => s.GetRunsPageAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((PipelineRunPage?)null);
        Assert.IsType<NotFoundResult>(await Sut().GetRuns("x", 1, 20, default));
    }

    // ---- GetStageDetail ----

    [Fact]
    public async Task GetStageDetail_FoundAndMissing()
    {
        _svc.Setup(s => s.GetStageDetailAsync("epic-web", 1, "build", It.IsAny<CancellationToken>()))
            .ReturnsAsync(new StageDetail { StageName = "build", Jobs = [] });
        Assert.IsType<OkObjectResult>(await Sut().GetStageDetail("epic-web", 1, "build", default));

        _svc.Setup(s => s.GetStageDetailAsync("epic-web", 2, "scan", It.IsAny<CancellationToken>()))
            .ReturnsAsync((StageDetail?)null);
        Assert.IsType<NotFoundResult>(await Sut().GetStageDetail("epic-web", 2, "scan", default));
    }

    // ---- GetStepLog ----

    [Fact]
    public async Task GetStepLog_FoundAndMissing()
    {
        _svc.Setup(s => s.GetStepLogAsync("epic-web", 1, 5, It.IsAny<CancellationToken>())).ReturnsAsync("log");
        Assert.IsType<OkObjectResult>(await Sut().GetStepLog("epic-web", 1, 5, default));

        _svc.Setup(s => s.GetStepLogAsync("epic-web", 1, 6, It.IsAny<CancellationToken>())).ReturnsAsync((string?)null);
        Assert.IsType<NotFoundResult>(await Sut().GetStepLog("epic-web", 1, 6, default));
    }

    // ---- GetScanResultUrl ----

    [Fact]
    public async Task GetScanResultUrl_FoundAndMissing()
    {
        _svc.Setup(s => s.GetScanResultUrlAsync("epic-web", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync("https://sonarqube.nonprod.pge.com/dashboard?id=epic-web&branch=main");
        Assert.IsType<OkObjectResult>(await Sut().GetScanResultUrl("epic-web", 1, default));

        _svc.Setup(s => s.GetScanResultUrlAsync("epic-web", 2, It.IsAny<CancellationToken>())).ReturnsAsync((string?)null);
        Assert.IsType<NotFoundResult>(await Sut().GetScanResultUrl("epic-web", 2, default));
    }

    // ---- Compliance endpoints ----

    [Fact]
    public async Task ComplianceReport_FoundAndMissing()
    {
        _svc.Setup(s => s.GetComplianceReportAsync("epic-web", 1, It.IsAny<CancellationToken>())).ReturnsAsync("# md");
        Assert.IsType<OkObjectResult>(await Sut().GetComplianceReport("epic-web", 1, default));

        _svc.Setup(s => s.GetComplianceReportAsync("epic-web", 2, It.IsAny<CancellationToken>())).ReturnsAsync((string?)null);
        Assert.IsType<NotFoundResult>(await Sut().GetComplianceReport("epic-web", 2, default));
    }

    [Fact]
    public async Task ComplianceSummary_FoundAndMissing()
    {
        _svc.Setup(s => s.GetComplianceSummaryAsync("epic-web", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ComplianceSummary { ByVerdict = new() });
        Assert.IsType<OkObjectResult>(await Sut().GetComplianceSummary("epic-web", 1, default));

        _svc.Setup(s => s.GetComplianceSummaryAsync("epic-web", 2, It.IsAny<CancellationToken>())).ReturnsAsync((ComplianceSummary?)null);
        Assert.IsType<NotFoundResult>(await Sut().GetComplianceSummary("epic-web", 2, default));
    }

    [Fact]
    public async Task ComplianceReportJson_FoundAndMissing()
    {
        _svc.Setup(s => s.GetComplianceReportJsonAsync("epic-web", 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ComplianceReport { Summary = new ComplianceSummary { ByVerdict = new() }, Findings = [] });
        Assert.IsType<OkObjectResult>(await Sut().GetComplianceReportJson("epic-web", 1, default));

        _svc.Setup(s => s.GetComplianceReportJsonAsync("epic-web", 2, It.IsAny<CancellationToken>())).ReturnsAsync((ComplianceReport?)null);
        Assert.IsType<NotFoundResult>(await Sut().GetComplianceReportJson("epic-web", 2, default));
    }

    // ---- CheckRepo ----

    [Fact]
    public async Task CheckRepo_Valid_Ok()
    {
        _svc.Setup(s => s.CheckRepoAsync("repo", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new RepoCheckResult { Status = "available" });
        Assert.IsType<OkObjectResult>(await Sut().CheckRepo("repo", null, default));
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    public async Task CheckRepo_Blank_BadRequest(string repo)
    {
        Assert.IsType<BadRequestObjectResult>(await Sut().CheckRepo(repo, null, default));
    }

    // ---- FindConfigs ----

    [Fact]
    public async Task FindConfigs_Valid_Ok()
    {
        _svc.Setup(s => s.FindConfigsAsync("repo", "main", It.IsAny<string?>(), It.IsAny<CancellationToken>())).ReturnsAsync(["epic.json"]);
        Assert.IsType<OkObjectResult>(await Sut().FindConfigs("repo", "main", null, default));
    }

    [Fact]
    public async Task FindConfigs_MissingParams_BadRequest()
    {
        Assert.IsType<BadRequestObjectResult>(await Sut().FindConfigs("", "main", null, default));
        Assert.IsType<BadRequestObjectResult>(await Sut().FindConfigs("repo", "", null, default));
    }

    // ---- CheckConfigInfra ----

    [Fact]
    public async Task CheckConfigInfra_Valid_Ok()
    {
        _svc.Setup(s => s.CheckConfigInfraAsync("repo", "main", "epic.json", It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ConfigCheckResult { HasInfra = true, AppType = "dotnet" });
        Assert.IsType<OkObjectResult>(await Sut().CheckConfigInfra("repo", "main", "epic.json", null, default));
    }

    [Fact]
    public async Task CheckConfigInfra_MissingParams_BadRequest()
    {
        Assert.IsType<BadRequestObjectResult>(await Sut().CheckConfigInfra("", "main", "c", null, default));
        Assert.IsType<BadRequestObjectResult>(await Sut().CheckConfigInfra("r", "", "c", null, default));
        Assert.IsType<BadRequestObjectResult>(await Sut().CheckConfigInfra("r", "main", "", null, default));
    }

    // ---- OnboardApp ----

    [Fact]
    public async Task OnboardApp_Created()
    {
        _svc.Setup(s => s.OnboardAppAsync("repo", It.IsAny<string?>(), It.IsAny<CancellationToken>())).ReturnsAsync(Detail("repo"));
        var result = await Sut().OnboardApp(new OnboardAppRequest { Repo = "repo" }, default);
        Assert.IsType<CreatedAtActionResult>(result);
    }

    [Fact]
    public async Task OnboardApp_KeyNotFound_NotFound()
    {
        _svc.Setup(s => s.OnboardAppAsync(It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new KeyNotFoundException("nope"));
        Assert.IsType<NotFoundObjectResult>(await Sut().OnboardApp(new OnboardAppRequest { Repo = "x" }, default));
    }

    [Fact]
    public async Task OnboardApp_InvalidOperation_BadRequest()
    {
        _svc.Setup(s => s.OnboardAppAsync(It.IsAny<string>(), It.IsAny<string?>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new InvalidOperationException("bad"));
        Assert.IsType<BadRequestObjectResult>(await Sut().OnboardApp(new OnboardAppRequest { Repo = "x" }, default));
    }

    // ---- TriggerRun ----

    [Fact]
    public async Task TriggerRun_Accepted()
    {
        _svc.Setup(s => s.TriggerRunAsync("epic-web", "main", "dev", ".pipeline/epic.json",
                true, true, false, false, false, false, "none", false, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new TriggerRunResponse { RunId = 1, Url = "u" });
        var req = new TriggerRunRequest { Branch = "main", Environment = "dev" };
        Assert.IsType<AcceptedResult>(await Sut().TriggerRun("epic-web", req, default));
    }

    [Fact]
    public async Task TriggerRun_KeyNotFound_NotFound()
    {
        _svc.Setup(s => s.TriggerRunAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(), It.IsAny<string>(),
                It.IsAny<bool>(), It.IsAny<bool>(), It.IsAny<bool>(), It.IsAny<bool>(), It.IsAny<bool>(), It.IsAny<bool>(),
                It.IsAny<string>(), It.IsAny<bool>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new KeyNotFoundException());
        var req = new TriggerRunRequest { Branch = "main", Environment = "dev" };
        Assert.IsType<NotFoundResult>(await Sut().TriggerRun("x", req, default));
    }

    // ---- CancelRun ----

    [Fact]
    public async Task CancelRun_NoContent()
    {
        _svc.Setup(s => s.CancelRunAsync("epic-web", 1, It.IsAny<CancellationToken>())).Returns(Task.CompletedTask);
        Assert.IsType<NoContentResult>(await Sut().CancelRun("epic-web", 1, default));
    }

    [Fact]
    public async Task CancelRun_KeyNotFound_NotFound()
    {
        _svc.Setup(s => s.CancelRunAsync(It.IsAny<string>(), It.IsAny<int>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new KeyNotFoundException());
        Assert.IsType<NotFoundResult>(await Sut().CancelRun("x", 1, default));
    }
}
