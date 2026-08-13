using System.IO.Compression;
using System.Net;
using System.Text;
using Epic.Api.Services;
using Epic.Api.UnitTests.TestHelpers;
using Xunit;

namespace Epic.Api.UnitTests.Services;

public sealed class AdoServiceTests
{
    private const int Engine = 194;
    private const int Orch = 133;

    private static AdoService Make(HttpMessageHandler handler, bool withPat = true)
    {
        var http = new HttpClient(handler);
        var config = withPat
            ? TestData.Config(("ADO_PAT", "test-pat"))
            : TestData.Config();
        return new AdoService(http, config, TestData.Logger<AdoService>(), TestData.NewCache());
    }

    // ---- Configuration guard ----

    [Fact]
    public async Task MissingPat_Throws()
    {
        var svc = Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.OK, "{}"), withPat: false);
        await Assert.ThrowsAsync<InvalidOperationException>(() => svc.GetTotalRunCountAsync("epic-web"));
    }

    // ---- GetRunsForAppAsync ----

    [Fact]
    public async Task GetRunsForApp_MapsBuild_AndResolvesStagesAndTriggeredBy()
    {
        var start = new DateTime(2026, 7, 1, 10, 0, 0, DateTimeKind.Utc);
        var finish = start.AddMinutes(5);
        var engineList = AdoJson.BuildList(AdoJson.Build(
            id: 500, status: "completed", result: "succeeded",
            branch: "feature/x", environment: "test", triggeredBy: "Morgan, Robb",
            startTime: start, finishTime: finish, engineIdTag: 500));
        var timeline = AdoJson.Timeline(
            AdoJson.StageRecord("s1", "Build", result: "succeeded"),
            AdoJson.StageRecord("s2", "Unit Tests", result: "succeeded"));
        var orchList = AdoJson.BuildList(AdoJson.Build(
            id: 499, status: "completed", result: "succeeded",
            triggeredBy: "Morgan, Robb", finishTime: start.AddMinutes(-1), engineIdTag: 500));

        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, engineList)
            .When("/timeline", HttpStatusCode.OK, timeline)
            .When($"definitions={Orch}", HttpStatusCode.OK, orchList);

        var runs = await Make(handler).GetRunsForAppAsync("epic-web");

        var run = Assert.Single(runs);
        Assert.Equal(500, run.Id);
        Assert.Equal("Success", run.Status);
        Assert.Equal("feature/x", run.Branch);
        Assert.Equal("test", run.Environment);
        Assert.Equal("Morgan, Robb", run.TriggeredBy);
        Assert.Equal("5m 00s", run.Duration);
        Assert.Equal(Epic.Api.Models.RunStatus.Success, run.Stages.Build);
        Assert.Equal(Epic.Api.Models.RunStatus.Success, run.Stages.Test);
        // Orchestrator linked by engineId tag → Prepare set + OrchestratorId set.
        Assert.Equal(499, run.OrchestratorId);
    }

    [Fact]
    public async Task GetRunsForApp_SkipsBuildsAtOrBeforeAfterBuildId()
    {
        var list = AdoJson.BuildList(
            AdoJson.Build(id: 10, branch: "main"),
            AdoJson.Build(id: 20, branch: "main"));
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, list)
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var runs = await Make(handler).GetRunsForAppAsync("epic-web", afterBuildId: 10);

        Assert.Single(runs);
        Assert.Equal(20, runs[0].Id);
    }

    [Fact]
    public async Task GetRunsForApp_NullResponse_ReturnsEmpty()
    {
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.InternalServerError, "{}");
        var runs = await Make(handler).GetRunsForAppAsync("epic-web");
        Assert.Empty(runs);
    }

    [Fact]
    public async Task GetRunsForApp_BranchFallsBackToParametersThenEpicBranchTag()
    {
        // No templateParameters branch; runtime "parameters" JSON provides it.
        var fromParams = AdoJson.Build(id: 1, parametersJson: "{\"branch\":\"from-params\",\"environment\":\"qa\"}");
        // No branch in params either — falls back to the epicBranch tag (URL-encoded).
        var fromTag = AdoJson.Build(id: 2, tags: ["epicBranch.feature%2Ffrom-tag"]);
        // sourceBranch (the epic-pipeline definition's own 'main') must NOT be used.
        var sourceIgnored = AdoJson.Build(id: 3, sourceBranch: "refs/heads/main");
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(fromParams, fromTag, sourceIgnored))
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var runs = await Make(handler).GetRunsForAppAsync("epic-web");

        Assert.Equal("from-params", runs.Single(r => r.Id == 1).Branch);
        Assert.Equal("qa", runs.Single(r => r.Id == 1).Environment);
        Assert.Equal("feature/from-tag", runs.Single(r => r.Id == 2).Branch);  // decoded
        Assert.Equal("", runs.Single(r => r.Id == 3).Branch);                  // no wrong "main"
    }

    [Fact]
    public async Task GetRunsForApp_UnparseableParameters_UsesDefaults()
    {
        var bad = AdoJson.Build(id: 1, parametersJson: "{not valid json");
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(bad))
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var runs = await Make(handler).GetRunsForAppAsync("epic-web");

        Assert.Equal("", runs[0].Branch);
        Assert.Equal("dev", runs[0].Environment);
    }

    // ---- GetRecentRunsForAppAsync ----

    [Fact]
    public async Task GetRecentRuns_ReadsTagsForCloudEnvAppTypeName()
    {
        var build = AdoJson.Build(
            id: 42, branch: "main",
            tags: ["epicCloud.aws", "epicEnvironment.prod", "epicAppType.dotnet", "epicAppName.epic-api"]);
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(build))
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var runs = await Make(handler).GetRecentRunsForAppAsync("epic-api");

        var run = Assert.Single(runs);
        Assert.Equal("aws", run.Cloud);
        Assert.Equal("prod", run.Environment);
        Assert.Equal("dotnet", run.AppType);
        Assert.Equal("epic-api", run.AppName);
    }

    [Fact]
    public async Task GetRecentRuns_IncludesUnmatchedRunningOrchestrator()
    {
        // Engine list empty; an orchestrator still running with no engine yet.
        var orch = AdoJson.Build(id: 700, status: "inProgress", result: null, branch: "main", triggeredBy: "Morgan, Robb");
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList(orch));

        var runs = await Make(handler).GetRecentRunsForAppAsync("epic-web");

        var run = Assert.Single(runs);
        Assert.Equal(700, run.Id);
        Assert.Equal("Running", run.Status);
        Assert.Equal("Morgan, Robb", run.TriggeredBy);
    }

    [Fact]
    public async Task GetRecentRuns_UnmatchedCiOrchestrator_BranchFromEpicBranchTag_NotSourceBranchMain()
    {
        // A CI (webhook) orchestrator in its Prepare phase: no templateParameters
        // branch yet (the orchestrator resolves it in a bash step), but it stamps
        // the resolved app branch as an epicBranch tag. sourceBranch is the
        // epic-pipeline definition's own 'main' and must NOT leak into the row.
        var orch = AdoJson.Build(id: 800, status: "inProgress", result: null,
            sourceBranch: "refs/heads/main", tags: ["epicBranch.feature%2Flogin", "epicRepo.epic-web"],
            triggeredBy: "Github CI");
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList(orch));

        var runs = await Make(handler).GetRecentRunsForAppAsync("epic-web");

        var run = Assert.Single(runs);
        Assert.Equal(800, run.Id);
        Assert.Equal("feature/login", run.Branch);  // decoded from the tag, never "main"
    }

    [Fact]
    public async Task GetRecentRuns_ExcludesStaleSucceededOrchestrator()
    {
        // Succeeded orchestrator that finished >2 min ago and never matched an engine → dropped.
        var stale = AdoJson.Build(id: 701, status: "completed", result: "succeeded",
            branch: "main", finishTime: DateTime.UtcNow.AddMinutes(-10));
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList(stale));

        var runs = await Make(handler).GetRecentRunsForAppAsync("epic-web");
        Assert.Empty(runs);
    }

    // ---- GetCompletedRunCountsAsync ----

    [Fact]
    public async Task GetCompletedRunCounts_TalliesTotalsAndDuration_SkippingCanceled()
    {
        var start = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc);
        var list = AdoJson.BuildList(
            AdoJson.Build(id: 1, result: "succeeded", startTime: start, finishTime: start.AddMinutes(2)),
            AdoJson.Build(id: 2, result: "failed", startTime: start, finishTime: start.AddMinutes(4)),
            AdoJson.Build(id: 3, result: "canceled", startTime: start, finishTime: start.AddMinutes(9)));
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.OK, list);

        var (total, successful, duration) = await Make(handler).GetCompletedRunCountsAsync("epic-web");

        Assert.Equal(2, total);       // canceled excluded
        Assert.Equal(1, successful);
        Assert.Equal(TimeSpan.FromMinutes(6), duration); // 2 + 4, canceled not counted
    }

    [Fact]
    public async Task GetCompletedRunCounts_FollowsContinuationToken()
    {
        var page1 = AdoJson.BuildList(AdoJson.Build(id: 1, result: "succeeded"));
        var page2 = AdoJson.BuildList(AdoJson.Build(id: 2, result: "succeeded"));
        var call = 0;
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains($"definitions={Engine}"), _ =>
            {
                call++;
                return call == 1
                    ? FakeHttpMessageHandler.Build(HttpStatusCode.OK, page1, continuationToken: "next")
                    : FakeHttpMessageHandler.Build(HttpStatusCode.OK, page2);
            });

        var (total, successful, _) = await Make(handler).GetCompletedRunCountsAsync("epic-web");

        Assert.Equal(2, total);
        Assert.Equal(2, successful);
    }

    [Fact]
    public async Task GetCompletedRunCounts_NullResponse_BreaksLoop()
    {
        var handler = new RoutingHttpMessageHandler()
            .When($"definitions={Engine}", HttpStatusCode.InternalServerError, "{}");
        var (total, successful, duration) = await Make(handler).GetCompletedRunCountsAsync("epic-web");
        Assert.Equal(0, total);
        Assert.Equal(0, successful);
        Assert.Equal(TimeSpan.Zero, duration);
    }

    // ---- GetTotalRunCountAsync (+ caching) ----

    [Fact]
    public async Task GetTotalRunCount_SumsPagesAndCaches()
    {
        var call = 0;
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains($"definitions={Engine}"), _ =>
            {
                call++;
                return FakeHttpMessageHandler.Build(HttpStatusCode.OK,
                    AdoJson.BuildList(AdoJson.Build(id: call, result: "succeeded")));
            });
        var svc = Make(handler);

        var first = await svc.GetTotalRunCountAsync("epic-web");
        var second = await svc.GetTotalRunCountAsync("epic-web");

        Assert.Equal(1, first);
        Assert.Equal(1, second);
        Assert.Equal(1, call); // second call served from cache
    }

    // ---- GetRunsPageAsync ----

    [Fact]
    public async Task GetRunsPage_ReturnsRequestedPage_WithTotal()
    {
        var start = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc);
        var pageCall = 0;
        // The page walk uses $top=1 (pageSize); the parallel total-count walk uses
        // $top=1000. Route on that so the two concurrent walks don't interfere.
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains($"definitions={Engine}") && r.RequestUri!.ToString().Contains("top=1000"),
                _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 1), AdoJson.Build(id: 2))))
            .When(r => r.RequestUri!.ToString().Contains($"definitions={Engine}"), _ =>
            {
                // Page walk: page 1 hands back a continuation token, page 2 is the target.
                var n = System.Threading.Interlocked.Increment(ref pageCall);
                return n == 1
                    ? FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 1, startTime: start)), continuationToken: "p2")
                    : FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 2, startTime: start.AddMinutes(1))));
            })
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var page = await Make(handler).GetRunsPageAsync("epic-web", page: 2, pageSize: 1);

        Assert.Equal(2, page.Total);
        var run = Assert.Single(page.Runs);
        Assert.Equal(2, run.Id);
    }

    [Fact]
    public async Task GetRunsPage_NegativePageAndSize_Normalized()
    {
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("statusFilter"),
                _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList()))
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 1)))
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var page = await Make(handler).GetRunsPageAsync("epic-web", page: -5, pageSize: -1);
        // page/pageSize normalized internally to 1/20; the single build comes back.
        Assert.Single(page.Runs);
    }

    [Fact]
    public async Task GetRunsPage_Page1_AddsUnmatchedFailedOrchestratorAsPrepareRow()
    {
        var start = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc);
        var failedOrch = AdoJson.Build(id: 900, status: "completed", result: "failed",
            branch: "main", triggeredBy: "Morgan, Robb", startTime: start.AddMinutes(5));
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("statusFilter"),
                _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 1))))
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList(AdoJson.Build(id: 1, startTime: start)))
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline())
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList(failedOrch));

        var page = await Make(handler).GetRunsPageAsync("epic-web", page: 1, pageSize: 20);

        Assert.Contains(page.Runs, r => r.Id == 900 && r.Status == "Failed");
    }

    [Fact]
    public async Task GetRunsPage_BeyondEnd_ReturnsEmptyRuns()
    {
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("statusFilter"),
                _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, AdoJson.BuildList()))
            .When($"definitions={Engine}", HttpStatusCode.OK, AdoJson.BuildList()) // no builds, no continuation
            .When($"definitions={Orch}", HttpStatusCode.OK, AdoJson.BuildList());

        var page = await Make(handler).GetRunsPageAsync("epic-web", page: 3, pageSize: 20);
        Assert.Empty(page.Runs);
    }

    // ---- Timeline / stage detail ----

    [Fact]
    public async Task GetStageDetail_ReturnsStepsSortedByOrder()
    {
        var s = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc);
        var timeline = AdoJson.Timeline(
            AdoJson.StageRecord("stage1", "Build", state: "completed", result: "succeeded"),
            AdoJson.Record("job1", "Job", "Build Job", "completed", "succeeded", parentId: "stage1"),
            AdoJson.Record("task2", "Task", "Second", "completed", "succeeded", parentId: "job1", order: 2, logId: 22, start: s, finish: s.AddSeconds(30)),
            AdoJson.Record("task1", "Task", "First", "completed", "succeeded", parentId: "job1", order: 1, logId: 11));
        var handler = new RoutingHttpMessageHandler().When("/timeline", HttpStatusCode.OK, timeline);

        var detail = await Make(handler).GetStageDetailAsync(1, "build");

        Assert.NotNull(detail);
        Assert.Equal("build", detail!.StageName);
        var steps = detail.Jobs.Single().Steps;
        Assert.Equal(2, steps.Count);
        Assert.Equal("First", steps[0].Name);   // order 1 first
        Assert.Equal("Second", steps[1].Name);
        Assert.Equal(22, steps[1].LogId);
        Assert.Equal("0m 30s", steps[1].Duration);
    }

    [Fact]
    public async Task GetStageDetail_NoTimeline_ReturnsNull()
    {
        var handler = new RoutingHttpMessageHandler().When("/timeline", HttpStatusCode.InternalServerError, "{}");
        Assert.Null(await Make(handler).GetStageDetailAsync(1, "build"));
    }

    [Fact]
    public async Task GetStageDetail_UnknownStage_ReturnsNull()
    {
        var timeline = AdoJson.Timeline(AdoJson.StageRecord("s1", "Build"));
        var handler = new RoutingHttpMessageHandler().When("/timeline", HttpStatusCode.OK, timeline);
        Assert.Null(await Make(handler).GetStageDetailAsync(1, "integrationTest"));
    }

    // ---- Step log ----

    [Fact]
    public async Task GetStepLog_ReturnsBody()
    {
        var handler = new RoutingHttpMessageHandler().When("/logs/", HttpStatusCode.OK, "log text");
        var log = await Make(handler).GetStepLogAsync(1, 5);
        Assert.Equal("log text", log);
    }

    [Fact]
    public async Task GetStepLog_NonSuccess_ReturnsNull()
    {
        var handler = new RoutingHttpMessageHandler().When("/logs/", HttpStatusCode.NotFound, "");
        Assert.Null(await Make(handler).GetStepLogAsync(1, 5));
    }

    [Fact]
    public async Task GetStepLog_FlattensJsonEnvelopeToLines()
    {
        // With Accept: application/json (see Program.cs) the ADO Logs API returns
        // {"count":N,"value":[...lines...]} rather than plain text. The service must
        // flatten "value" back into newline-joined text so the UI doesn't render it
        // as one unreadable line.
        var handler = new RoutingHttpMessageHandler().When("/logs/", HttpStatusCode.OK,
            "{\"count\":2,\"value\":[\"##[section]Starting: Build app\",\"2026-07-15T14:01:39Z done\"]}");
        var log = await Make(handler).GetStepLogAsync(1, 5);
        Assert.Equal("##[section]Starting: Build app\n2026-07-15T14:01:39Z done", log);
    }

    // ---- Scan result URL ----

    private static string ScanTimeline() => AdoJson.Timeline(
        AdoJson.StageRecord("s1", "Scan App", state: "completed", result: "succeeded"),
        AdoJson.Record("j1", "Job", "Scan Job", "completed", "succeeded", parentId: "s1"),
        AdoJson.Record("t1", "Task", "Analyze code", "completed", "succeeded", parentId: "j1", order: 1, logId: 42));

    [Fact]
    public async Task GetScanResultUrl_ExtractsUrlFromAnalyzeLog()
    {
        var handler = new RoutingHttpMessageHandler()
            .When("/timeline", HttpStatusCode.OK, ScanTimeline())
            .When("/logs/", HttpStatusCode.OK,
                "INFO: ANALYSIS SUCCESSFUL, you can find the results at: https://sonarqube.nonprod.pge.com/dashboard?id=epic-web&branch=main\nINFO: done");

        var url = await Make(handler).GetScanResultUrlAsync(1);
        Assert.Equal("https://sonarqube.nonprod.pge.com/dashboard?id=epic-web&branch=main", url);
    }

    [Fact]
    public async Task GetScanResultUrl_StopsAtJsonStringBoundary()
    {
        // The ADO logs endpoint returns the log as a JSON array of strings, so the
        // raw body places a `","` delimiter (and the next line's timestamp) right
        // after the URL. Regression: a greedy \S+ ate across the delimiter and
        // produced ...branch=main%22,%222026-... — the fix stops the capture at ".
        var handler = new RoutingHttpMessageHandler()
            .When("/timeline", HttpStatusCode.OK, ScanTimeline())
            .When("/logs/", HttpStatusCode.OK,
                "{\"count\":2,\"value\":[\"INFO: ANALYSIS SUCCESSFUL, you can find the results at: https://sonarqube.nonprod.pge.com/dashboard?id=epic-api&branch=main\",\"2026-07-14T19:56:22.0723802Z INFO: done\"]}");

        var url = await Make(handler).GetScanResultUrlAsync(1);
        Assert.Equal("https://sonarqube.nonprod.pge.com/dashboard?id=epic-api&branch=main", url);
    }

    [Fact]
    public async Task GetScanResultUrl_NoUrlInLog_ReturnsNull()
    {
        var handler = new RoutingHttpMessageHandler()
            .When("/timeline", HttpStatusCode.OK, ScanTimeline())
            .When("/logs/", HttpStatusCode.OK, "INFO: analysis ran but no URL line here");
        Assert.Null(await Make(handler).GetScanResultUrlAsync(1));
    }

    [Fact]
    public async Task GetScanResultUrl_NoAnalyzeStep_ReturnsNull()
    {
        // Wiz scan (or any non-SonarQube scan) has no "Analyze code" step.
        var timeline = AdoJson.Timeline(
            AdoJson.StageRecord("s1", "Scan App", state: "completed", result: "succeeded"),
            AdoJson.Record("j1", "Job", "Scan Job", "completed", "succeeded", parentId: "s1"),
            AdoJson.Record("t1", "Task", "Wiz Scan", "completed", "succeeded", parentId: "j1", order: 1, logId: 42));
        var handler = new RoutingHttpMessageHandler().When("/timeline", HttpStatusCode.OK, timeline);
        Assert.Null(await Make(handler).GetScanResultUrlAsync(1));
    }

    [Fact]
    public async Task GetScanResultUrl_NoScanStage_ReturnsNull()
    {
        var handler = new RoutingHttpMessageHandler()
            .When("/timeline", HttpStatusCode.OK, AdoJson.Timeline(AdoJson.StageRecord("s1", "Build")));
        Assert.Null(await Make(handler).GetScanResultUrlAsync(1));
    }

    // ---- Trigger orchestrator ----

    [Fact]
    public async Task TriggerOrchestrator_PostsAndReturnsRunIdAndUrl()
    {
        RoutingHttpMessageHandler handler = new();
        handler.When("/runs?api-version", HttpStatusCode.OK, "{\"id\":12345}");

        var result = await Make(handler).TriggerOrchestratorAsync(
            "epic-web", "main", "dev", "epic.json",
            review: true, build: true, tests: false, scan: false, deploy: false, integrations: false,
            deployInfra: "none", forceStateCopy: false, triggeredBy: "Morgan, Robb",
            owner: "pgetech", githubHost: "github.com");

        Assert.Equal(12345, result.RunId);
        Assert.Contains("buildId=12345", result.Url);
        var posted = handler.Requests.Single();
        Assert.Equal(HttpMethod.Post, posted.Method);
    }

    [Fact]
    public async Task TriggerOrchestrator_NonSuccess_Throws()
    {
        var handler = new RoutingHttpMessageHandler().When("/runs?api-version", HttpStatusCode.BadRequest, "bad");
        await Assert.ThrowsAsync<AdoUpstreamException>(() => Make(handler).TriggerOrchestratorAsync(
            "epic-web", "main", "dev", "epic.json",
            true, true, false, false, false, false, "none", false, "Morgan, Robb",
            "pgetech", "github.com"));
    }

    // ---- Cancel build ----

    [Fact]
    public async Task CancelBuild_Success_NoThrow()
    {
        RoutingHttpMessageHandler handler = new();
        handler.When(r => r.Method == HttpMethod.Patch, _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, "{}"));
        await Make(handler).CancelBuildAsync(1); // no exception
    }

    [Theory]
    [InlineData(HttpStatusCode.BadRequest)]
    [InlineData(HttpStatusCode.NotFound)]
    public async Task CancelBuild_AlreadyDone_IsNoOp(HttpStatusCode code)
    {
        RoutingHttpMessageHandler handler = new();
        handler.When(r => r.Method == HttpMethod.Patch, _ => FakeHttpMessageHandler.Build(code, "{}"));
        await Make(handler).CancelBuildAsync(1); // idempotent — no throw
    }

    [Fact]
    public async Task CancelBuild_ServerError_Throws()
    {
        RoutingHttpMessageHandler handler = new();
        handler.When(r => r.Method == HttpMethod.Patch, _ => FakeHttpMessageHandler.Build(HttpStatusCode.InternalServerError, "boom"));
        await Assert.ThrowsAsync<AdoUpstreamException>(() => Make(handler).CancelBuildAsync(1));
    }

    // ---- Compliance artifact ----

    private static byte[] Zip(string entryName, string content)
    {
        using var ms = new MemoryStream();
        using (var archive = new ZipArchive(ms, ZipArchiveMode.Create, leaveOpen: true))
        {
            var entry = archive.CreateEntry(entryName);
            using var writer = new StreamWriter(entry.Open());
            writer.Write(content);
        }
        return ms.ToArray();
    }

    private static RoutingHttpMessageHandler ArtifactHandler(byte[] zipBytes, string downloadUrl = "https://artifacts.example/download")
    {
        var meta = $"{{\"resource\":{{\"downloadUrl\":{System.Text.Json.JsonSerializer.Serialize(downloadUrl)}}}}}";
        var handler = new RoutingHttpMessageHandler()
            .When("/artifacts?artifactName", HttpStatusCode.OK, meta)
            .When(r => r.RequestUri!.ToString() == downloadUrl, _ =>
            {
                var resp = new HttpResponseMessage(HttpStatusCode.OK) { Content = new ByteArrayContent(zipBytes) };
                return resp;
            });
        return handler;
    }

    [Fact]
    public async Task GetComplianceReport_ReturnsMarkdownEntry()
    {
        var handler = ArtifactHandler(Zip("compliance-report.md", "# Report"));
        var md = await Make(handler).GetComplianceReportAsync(1);
        Assert.Equal("# Report", md);
    }

    [Fact]
    public async Task GetComplianceReportJson_ParsesSummaryProfileFindings()
    {
        var json = """
        {
          "metadata": { "tool": "epic-compliance", "version": "v1.1.3", "specSource": "APP.md", "scannedAt": "2026-07-13" },
          "summary": { "total": 3, "byVerdict": { "PASS": 1, "FAIL": 2 } },
          "profile": { "kinds": ["spa"], "authModel": "delegated", "idp": "Entra ID", "narrative": "n" },
          "findings": [
            { "control": { "nistId": "AC-12", "title": "Session", "requirement": "req" },
              "verdict": "PASS", "kind": "code", "severity": "hard", "message": "m", "remediation": "r",
              "inheritedFrom": null,
              "evidence": [ { "file": "a.cs", "line": 10 }, { "file": "b.cs" } ] }
          ]
        }
        """;
        var handler = ArtifactHandler(Zip("compliance-report.json", json));
        var report = await Make(handler).GetComplianceReportJsonAsync(1);

        Assert.NotNull(report);
        Assert.Equal("v1.1.3", report!.Summary.Version);
        Assert.Equal(3, report.Summary.Total);
        Assert.Equal(2, report.Summary.ByVerdict["FAIL"]);
        Assert.Equal("spa", report.Profile!.Kinds!.Single());
        var f = Assert.Single(report.Findings);
        Assert.Equal("AC-12", f.NistId);
        Assert.Equal(["a.cs:10", "b.cs"], f.Evidence);
    }

    [Fact]
    public async Task GetComplianceSummary_DerivesFromJsonReport()
    {
        var json = "{\"metadata\":{\"version\":\"v1\"},\"summary\":{\"total\":1,\"byVerdict\":{\"PASS\":1}}}";
        var handler = ArtifactHandler(Zip("compliance-report.json", json));
        var summary = await Make(handler).GetComplianceSummaryAsync(1);
        Assert.NotNull(summary);
        Assert.Equal("v1", summary!.Version);
        Assert.Equal(1, summary.Total);
    }

    [Fact]
    public async Task GetComplianceReportJson_BadJson_ReturnsNull()
    {
        var handler = ArtifactHandler(Zip("compliance-report.json", "{ not json"));
        Assert.Null(await Make(handler).GetComplianceReportJsonAsync(1));
    }

    [Fact]
    public async Task GetComplianceReportJson_NonNumericCounts_SkippedNotThrown()
    {
        // Valid JSON but a verdict count / total is a string (format drift). Must
        // not throw (would escape the JsonException-only catch → 500) — skip the
        // bad count and default total to 0.
        var json = """
        {
          "metadata": { "version": "v1" },
          "summary": { "total": "oops", "byVerdict": { "PASS": 2, "FAIL": "many" } }
        }
        """;
        var handler = ArtifactHandler(Zip("compliance-report.json", json));
        var report = await Make(handler).GetComplianceReportJsonAsync(1);

        Assert.NotNull(report);
        Assert.Equal(0, report!.Summary.Total);              // non-numeric → default
        Assert.Equal(2, report.Summary.ByVerdict["PASS"]);   // good count kept
        Assert.False(report.Summary.ByVerdict.ContainsKey("FAIL"));   // bad count skipped
    }

    [Fact]
    public async Task GetComplianceReport_NoArtifactMeta_ReturnsNull()
    {
        var handler = new RoutingHttpMessageHandler()
            .When("/artifacts?artifactName", HttpStatusCode.NotFound, "");
        Assert.Null(await Make(handler).GetComplianceReportAsync(1));
    }

    [Fact]
    public async Task GetComplianceReport_MetaWithoutDownloadUrl_ReturnsNull()
    {
        var handler = new RoutingHttpMessageHandler()
            .When("/artifacts?artifactName", HttpStatusCode.OK, "{\"resource\":{}}");
        Assert.Null(await Make(handler).GetComplianceReportAsync(1));
    }

    [Fact]
    public async Task GetComplianceReport_DownloadFails_ReturnsNull()
    {
        var meta = "{\"resource\":{\"downloadUrl\":\"https://artifacts.example/dl\"}}";
        var handler = new RoutingHttpMessageHandler()
            .When("/artifacts?artifactName", HttpStatusCode.OK, meta)
            .When(r => r.RequestUri!.ToString() == "https://artifacts.example/dl",
                _ => FakeHttpMessageHandler.Build(HttpStatusCode.InternalServerError, ""));
        Assert.Null(await Make(handler).GetComplianceReportAsync(1));
    }

    [Fact]
    public async Task GetComplianceReport_ZipMissingExtension_ReturnsNull()
    {
        var handler = ArtifactHandler(Zip("something.txt", "x"));
        Assert.Null(await Make(handler).GetComplianceReportAsync(1)); // wants .md
    }
}
