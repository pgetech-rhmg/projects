using System.Net;
using Epic.Api.Models;
using Epic.Api.Services;
using Epic.Api.UnitTests.TestHelpers;
using Xunit;

namespace Epic.Api.UnitTests.Services;

/// <summary>
/// Branch-completion tests for AdoService: the status/stage mapping arms and the
/// branch-resolution fallbacks in the lightweight (GetRecentRuns) and paged
/// (MapBuildToRunAsync) code paths that the primary AdoServiceTests don't reach.
/// </summary>
public sealed class AdoServiceCoverageTests
{
    private const int Engine = 194;
    private const int Orch = 133;

    private static AdoService Make(HttpMessageHandler handler)
    {
        var http = new HttpClient(handler);
        return new AdoService(http, TestData.Logger<AdoService>(), TestData.NewCache());
    }

    // ---- GetRecentRuns branch fallbacks ----

    [Fact]
    public async Task GetRecentRuns_BranchFromParametersAndEpicBranchTag_AndUnparseable()
    {
        var fromParams = AdoJson.Build(id: 1, parametersJson: "{\"branch\":\"pb\",\"environment\":\"qa\"}");
        var fromTag = AdoJson.Build(id: 2, tags: ["epicBranch.sb"]);
        var unparseable = AdoJson.Build(id: 3, parametersJson: "{bad");
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(fromParams, fromTag, unparseable))
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var runs = await Make(handler).GetRecentRunsForAppAsync("epic-web");

        Assert.Equal("pb", runs.Single(r => r.Id == 1).Branch);
        Assert.Equal("qa", runs.Single(r => r.Id == 1).Environment);
        Assert.Equal("sb", runs.Single(r => r.Id == 2).Branch);
        Assert.Equal("", runs.Single(r => r.Id == 3).Branch);  // no branch anywhere → blank, never "main"
    }

    // ---- MapBuildToRunAsync (via GetRunsPage) branch fallbacks + tags ----

    [Fact]
    public async Task GetRunsPage_MapBuild_ParamsFallback_SourceBranch_Tags()
    {
        var start = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc);
        var fromParams = AdoJson.Build(id: 1, parametersJson: "{\"branch\":\"pb\",\"environment\":\"stage\"}",
            startTime: start, tags: ["epicAppName.web", "epicCloud.azure", "epicEnvironment.prod"]);
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("top=1000"),
                _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(fromParams)))
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(fromParams))
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var page = await Make(handler).GetRunsPageAsync("web", 1, 20);

        var run = page.Runs.Single(r => r.Id == 1);
        Assert.Equal("pb", run.Branch);
        Assert.Equal("prod", run.Environment);   // tag overrides templateParameters
        Assert.Equal("azure", run.Cloud);
        Assert.Equal("web", run.AppName);
    }

    [Fact]
    public async Task GetRunsPage_MapBuild_EpicBranchTagFallback_AndUnparseableParams()
    {
        var start = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc);
        // Unparseable params + a sourceBranch that must be ignored; branch comes from the tag.
        var build = AdoJson.Build(id: 1, parametersJson: "{bad", sourceBranch: "refs/heads/main",
            tags: ["epicBranch.sb"], startTime: start);
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("top=1000"),
                _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(build)))
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(build))
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var page = await Make(handler).GetRunsPageAsync("web", 1, 20);
        Assert.Equal("sb", page.Runs.Single(r => r.Id == 1).Branch);  // from epicBranch tag, not sourceBranch=main
    }

    // ---- Stage-name mapping arms (all stages + alt names) ----

    [Fact]
    public async Task GetStageResults_MapsEveryStageName()
    {
        var timeline = AdoJson.Timeline(
            AdoJson.StageRecord("d", "Download Source", result: "succeeded"),
            AdoJson.StageRecord("r", "Review App", result: "succeeded"),
            AdoJson.StageRecord("b", "Build App", result: "succeeded"),
            AdoJson.StageRecord("t", "BuildTest", result: "succeeded"),
            AdoJson.StageRecord("sc", "Scan App", result: "succeeded"),
            AdoJson.StageRecord("di", "Deploy Infrastructure", result: "succeeded"),
            AdoJson.StageRecord("ad", "Deploy App", result: "succeeded"),
            AdoJson.StageRecord("it", "Integration Tests", result: "succeeded"));
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 1, branch: "main")))
            .When("/timeline", HttpStatusCode.OK, timeline)
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var run = (await Make(handler).GetRunsForAppAsync("web")).Single();
        Assert.Equal(RunStatus.Success, run.Stages.Download);
        Assert.Equal(RunStatus.Success, run.Stages.Review);
        Assert.Equal(RunStatus.Success, run.Stages.Build);
        Assert.Equal(RunStatus.Success, run.Stages.Test);
        Assert.Equal(RunStatus.Success, run.Stages.Scan);
        Assert.Equal(RunStatus.Success, run.Stages.InfraDeploy);
        Assert.Equal(RunStatus.Success, run.Stages.AppDeploy);
        Assert.Equal(RunStatus.Success, run.Stages.IntegrationTest);
    }

    // ---- Terminal reconciliation: Running→Canceled, Pending→Skipped ----

    [Fact]
    public async Task GetStageResults_TerminalRun_ReconcilesInProgressAndPending()
    {
        // Build completed (terminal) but a stage is still inProgress and another pending.
        var timeline = AdoJson.Timeline(
            AdoJson.StageRecord("b", "Build", state: "inProgress", result: null),
            AdoJson.StageRecord("t", "BuildTest", state: "pending", result: null));
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK,
                AdoJson.BuildList(AdoJson.Build(id: 1, status: "completed", result: "succeeded", branch: "main")))
            .When("/timeline", HttpStatusCode.OK, timeline)
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var run = (await Make(handler).GetRunsForAppAsync("web")).Single();
        Assert.Equal(RunStatus.Canceled, run.Stages.Build);   // Running → Canceled
        Assert.Equal(RunStatus.Skipped, run.Stages.Test);     // Pending → Skipped
    }

    // ---- MapRunStatus arms ----

    [Theory]
    [InlineData("completed", "failed", "Failed")]
    [InlineData("completed", "canceled", "Canceled")]
    [InlineData("completed", "weird", "Failed")]     // unknown result on completed
    [InlineData("canceling", null, "Canceled")]
    [InlineData("notStarted", null, "Running")]
    [InlineData("someOtherState", null, "Running")]  // default arm
    public async Task MapRunStatus_Arms(string state, string? result, string expected)
    {
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK,
                AdoJson.BuildList(AdoJson.Build(id: 1, status: state, result: result, branch: "main")))
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var run = (await Make(handler).GetRunsForAppAsync("web")).Single();
        Assert.Equal(expected, run.Status);
    }

    // ---- MapStageStatus arms (via stage detail) ----

    [Theory]
    [InlineData("completed", "failed", RunStatus.Failed)]
    [InlineData("completed", "cancelled", RunStatus.Canceled)]  // British spelling arm
    [InlineData("completed", "skipped", RunStatus.Skipped)]
    [InlineData("completed", "mystery", RunStatus.Failed)]
    [InlineData("inProgress", null, RunStatus.Running)]
    [InlineData("pending", null, RunStatus.Pending)]
    [InlineData("weird", null, RunStatus.Pending)]
    public async Task MapStageStatus_Arms(string state, string? result, RunStatus expected)
    {
        var timeline = AdoJson.Timeline(AdoJson.StageRecord("s", "Build", state: state, result: result));
        var handler = new RoutingHttpMessageHandler().When("/timeline", HttpStatusCode.OK, timeline);
        var detail = await Make(handler).GetStageDetailAsync(1, "build");
        Assert.Equal(expected, detail!.Status);
    }

    // ---- MatchesStageName arms (via GetStageDetail for each stage key) ----

    [Theory]
    [InlineData("review", "Review App")]
    [InlineData("build", "Build")]
    [InlineData("test", "BuildTest")]
    [InlineData("scan", "Scan App")]
    [InlineData("infraDeploy", "Deploy Infrastructure")]
    [InlineData("appDeploy", "Deploy App")]
    [InlineData("integrationTest", "Integration Tests")]
    public async Task GetStageDetail_MatchesEachStageKey(string stageKey, string recordName)
    {
        var timeline = AdoJson.Timeline(AdoJson.StageRecord("s", recordName, result: "succeeded"));
        var handler = new RoutingHttpMessageHandler().When("/timeline", HttpStatusCode.OK, timeline);
        var detail = await Make(handler).GetStageDetailAsync(1, stageKey);
        Assert.NotNull(detail);
        Assert.Equal(stageKey, detail!.StageName);
    }

    [Fact]
    public async Task GetStageDetail_UnknownStageKey_NoMatch_ReturnsNull()
    {
        // An unrecognized stage key hits the MatchesStageName default (_ => false).
        var timeline = AdoJson.Timeline(AdoJson.StageRecord("s", "Build", result: "succeeded"));
        var handler = new RoutingHttpMessageHandler().When("/timeline", HttpStatusCode.OK, timeline);
        Assert.Null(await Make(handler).GetStageDetailAsync(1, "bogusStage"));
    }

    // ---- GetTotalRunCount: continuation walk ----

    [Fact]
    public async Task GetTotalRunCount_FollowsContinuationToken()
    {
        var call = 0;
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains($"definitions={Engine}"), _ =>
            {
                call++;
                return call == 1
                    ? FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 1), AdoJson.Build(id: 2)), continuationToken: "next")
                    : FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 3)));
            });
        var total = await Make(handler).GetTotalRunCountAsync("web");
        Assert.Equal(3, total);
    }

    // ---- Orchestrator: unparseable runtime parameters caught ----

    [Fact]
    public async Task GetRunsForApp_OrchestratorUnparseableParams_Caught()
    {
        var start = new DateTime(2026, 7, 1, 10, 0, 0, DateTimeKind.Utc);
        var engine = AdoJson.Build(id: 500, branch: "main", startTime: start, engineIdTag: 500);
        var orch = AdoJson.Build(id: 499, status: "completed", result: "succeeded",
            parametersJson: "{bad json", finishTime: start.AddMinutes(-1), engineIdTag: 500);
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(engine))
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList(orch));

        var run = (await Make(handler).GetRunsForAppAsync("web")).Single();
        Assert.Equal(499, run.OrchestratorId); // still links despite bad params
    }

    // ---- MapRunStatus inProgress arm ----

    [Fact]
    public async Task MapRunStatus_InProgress_IsRunning()
    {
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK,
                AdoJson.BuildList(AdoJson.Build(id: 1, status: "inProgress", result: null, branch: "main")))
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());
        var run = (await Make(handler).GetRunsForAppAsync("web")).Single();
        Assert.Equal("Running", run.Status);
    }

    // ---- GetRunsPage: templateParameters branch + multi-page continuation walk ----

    [Fact]
    public async Task GetRunsPage_WalksContinuationToTargetPage_WithTemplateParamsBranch()
    {
        var start = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc);
        var pageCall = 0;
        // Engine page walk is stateful: page 1 → token, page 2 → token, page 3 is the target.
        var stateful = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("top=1000"),
                _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 1))))
            .When(r => r.RequestUri!.ToString().Contains($"definitions={Engine}"), _ =>
            {
                var n = System.Threading.Interlocked.Increment(ref pageCall);
                if (n < 3)
                    return FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: n, branch: $"b{n}", startTime: start)), continuationToken: $"t{n}");
                return FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 3, branch: "target", environment: "prod", startTime: start)));
            })
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var page = await Make(stateful).GetRunsPageAsync("web", page: 3, pageSize: 10);
        var run = Assert.Single(page.Runs);
        Assert.Equal("target", run.Branch);   // templateParameters branch
        Assert.Equal("prod", run.Environment);
    }

    // ---- Orchestrator resolve: branch from runtime parameters fallback ----

    [Fact]
    public async Task GetRunsForApp_OrchestratorBranchFromParametersFallback()
    {
        var start = new DateTime(2026, 7, 1, 10, 0, 0, DateTimeKind.Utc);
        var engine = AdoJson.Build(id: 500, branch: "main", startTime: start, engineIdTag: 500);
        // Orchestrator has no templateParameters branch — only runtime parameters JSON.
        var orch = AdoJson.Build(id: 499, status: "completed", result: "succeeded",
            parametersJson: "{\"branch\":\"ob\",\"environment\":\"qa\"}",
            finishTime: start.AddMinutes(-1), engineIdTag: 500);
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(engine))
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList(orch));

        var run = (await Make(handler).GetRunsForAppAsync("web")).Single();
        Assert.Equal(499, run.OrchestratorId); // linked, params parsed without throwing
    }

    // ---- Timeline caching: terminal run cached, served on 2nd call ----

    [Fact]
    public async Task GetStageResults_TerminalRun_CachesTimeline()
    {
        var calls = 0;
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK,
                AdoJson.BuildList(AdoJson.Build(id: 1, status: "completed", result: "succeeded", branch: "main")))
            .When(r => r.RequestUri!.ToString().Contains("/timeline"), _ =>
            {
                calls++;
                return FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.Timeline(AdoJson.StageRecord("b", "Build", result: "succeeded")));
            })
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());
        var svc = Make(handler);

        await svc.GetRunsForAppAsync("web");
        await svc.GetRunsForAppAsync("web");
        Assert.Equal(1, calls); // 2nd resolution served from timeline cache
    }

    // ---- Compliance report: profile absent, evidence absent ----

    [Fact]
    public async Task GetComplianceReportJson_NoProfileNoEvidence_StillParses()
    {
        var json = "{\"metadata\":{\"version\":\"v1\"},\"summary\":{\"total\":1,\"byVerdict\":{}}," +
                   "\"findings\":[{\"control\":{\"nistId\":\"AC-01\"},\"verdict\":\"PASS\"}]}";
        var handler = AdoServiceTests_ArtifactHandler(json);
        var report = await Make(handler).GetComplianceReportJsonAsync(1);
        Assert.NotNull(report);
        Assert.Null(report!.Profile);
        var f = Assert.Single(report.Findings);
        Assert.Null(f.Evidence);
    }

    [Fact]
    public async Task GetComplianceReportJson_ProfileWithoutKinds_KindsNull()
    {
        // profile present but no "kinds" array → GetStringListOrNull returns null.
        var json = "{\"metadata\":{\"version\":\"v1\"},\"summary\":{\"total\":0,\"byVerdict\":{}}," +
                   "\"profile\":{\"authModel\":\"delegated\",\"idp\":\"Entra ID\"},\"findings\":[]}";
        var report = await Make(AdoServiceTests_ArtifactHandler(json)).GetComplianceReportJsonAsync(1);
        Assert.NotNull(report!.Profile);
        Assert.Null(report.Profile!.Kinds);
        Assert.Equal("delegated", report.Profile.AuthModel);
    }

    // Reuse the same artifact-zip approach as AdoServiceTests.
    private static RoutingHttpMessageHandler AdoServiceTests_ArtifactHandler(string jsonContent)
    {
        var zip = ZipBytes("compliance-report.json", jsonContent);
        var meta = "{\"resource\":{\"downloadUrl\":\"https://a/dl\"}}";
        return new RoutingHttpMessageHandler()
            .When("/artifacts?artifactName", HttpStatusCode.OK, meta)
            .When(r => r.RequestUri!.ToString() == "https://a/dl",
                _ => new HttpResponseMessage(HttpStatusCode.OK) { Content = new ByteArrayContent(zip) });
    }

    private static byte[] ZipBytes(string name, string content)
    {
        using var ms = new MemoryStream();
        using (var archive = new System.IO.Compression.ZipArchive(ms, System.IO.Compression.ZipArchiveMode.Create, true))
        {
            using var w = new StreamWriter(archive.CreateEntry(name).Open());
            w.Write(content);
        }
        return ms.ToArray();
    }
}
