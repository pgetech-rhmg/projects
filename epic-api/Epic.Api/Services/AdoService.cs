using System.Net.Http.Headers;
using System.Text.Json;
using Epic.Api.Models;
using Microsoft.Extensions.Caching.Memory;

namespace Epic.Api.Services;

public sealed class AdoService(HttpClient httpClient, IConfiguration configuration, ILogger<AdoService> logger, IMemoryCache cache) : IAdoService
{
    // Timelines for completed builds are immutable — cache for 24h.
    private static readonly TimeSpan TimelineCacheTtl = TimeSpan.FromHours(24);
    // Total run counts can lag briefly — page 1 still surfaces new runs immediately.
    private static readonly TimeSpan TotalCountCacheTtl = TimeSpan.FromSeconds(30);

    private const string Org = "pgetech";
    private const string Project = "EPIC-Pipeline";
    private const int EnginePipelineId = 194;
    private const int OrchestratorPipelineId = 133;

    // ADO REST JSON property names (repeated across the build/timeline parsers).
    private const string PropValue = "value";
    private const string PropStatus = "status";
    private const string PropResult = "result";
    private const string PropTemplateParameters = "templateParameters";
    private const string PropParameters = "parameters";
    private const string PropBranch = "branch";
    private const string PropEnvironment = "environment";
    private const string PropStartTime = "startTime";
    private const string PropQueueTime = "queueTime";
    private const string PropFinishTime = "finishTime";

    // Repeated tag prefixes, status strings, and misc literals.
    private const string TagCloudPrefix = "epicCloud.";
    private const string TagEnvironmentPrefix = "epicEnvironment.";
    private const string TagAppNamePrefix = "epicAppName.";
    private const string TagBranchPrefix = "epicBranch.";
    private const string StatusRunning = "Running";
    private const string StatusFailed = "Failed";
    private const string SystemActor = "System";
    private const string DefaultEnvironment = "dev";
    private const string UnknownStatus = "unknown";
    private const string BasicScheme = "Basic";
    private const string UnparseableParamsLog = "ADO build parameters not parseable — using defaults";

    private string Pat =>
        configuration["ADO_PAT"]
        ?? throw new InvalidOperationException("ADO_PAT not configured.");

    private static string BaseUrl => $"https://dev.azure.com/{Org}/{Project}/_apis";

    // Reads a DateTime-valued property, treating absent/null as no value.
    private static DateTime? ParseOptionalTime(JsonElement build, string property) =>
        build.TryGetProperty(property, out var prop) && prop.ValueKind != JsonValueKind.Null
            ? prop.GetDateTime()
            : null;

    // A build's effective start: its startTime, else its queueTime, else now.
    private static DateTime ParseStartTime(JsonElement build) =>
        ParseOptionalTime(build, PropStartTime)
        ?? ParseOptionalTime(build, PropQueueTime)
        ?? DateTime.UtcNow;

    // Reads a string property off a JSON object, or "" if absent/non-string.
    private static string GetStringOrEmpty(JsonElement obj, string property) =>
        obj.TryGetProperty(property, out var v) ? v.GetString() ?? "" : "";

    // Resolves a build's branch + environment from, in order: the engine's
    // templateParameters, the orchestrator's runtime "parameters" JSON blob, and
    // finally the EPIC-stamped epicBranch tag. Shared by every build-mapping path
    // so the fallback chain lives in one place (was duplicated 4×).
    //
    // The epicBranch tag is what lets a CI orchestrator's "prepare" row show the
    // real app branch before the engine build (which carries branch in
    // templateParameters) exists. We deliberately do NOT fall back to the build's
    // raw sourceBranch: for both orchestrator and engine builds that is the
    // epic-pipeline definition's own branch (always 'main'), never the app's
    // branch — so it would surface a wrong "main" while a run is pending.
    private (string Branch, string Environment) ResolveBranchAndEnvironment(JsonElement build)
    {
        var branch = "";
        var environment = DefaultEnvironment;

        if (build.TryGetProperty(PropTemplateParameters, out var tp) && tp.ValueKind == JsonValueKind.Object)
        {
            branch = GetStringOrEmpty(tp, PropBranch);
            environment = GetStringOrEmpty(tp, PropEnvironment) is { Length: > 0 } e ? e : DefaultEnvironment;
        }

        if (string.IsNullOrEmpty(branch)
            && build.TryGetProperty(PropParameters, out var p) && p.ValueKind == JsonValueKind.String
            && p.GetString() is { } paramsString)
        {
            try
            {
                var paramObj = JsonDocument.Parse(paramsString).RootElement;
                branch = GetStringOrEmpty(paramObj, PropBranch);
                environment = GetStringOrEmpty(paramObj, PropEnvironment) is { Length: > 0 } e ? e : DefaultEnvironment;
            }
            catch (Exception ex) { logger.LogDebug(ex, UnparseableParamsLog); }
        }

        if (string.IsNullOrEmpty(branch))
            branch = ReadEpicTags(build).Branch ?? "";

        return (branch, environment);
    }

    // Extracts the epic* tag values (cloud/environment/appType/appName/branch) a
    // build is stamped with, if present. The orchestrator URL-encodes '/' in the
    // branch tag (feature/x → feature%2Fx) so the tag path is valid; decode it.
    private static (string? Cloud, string? Environment, string? AppType, string? AppName, string? Branch) ReadEpicTags(JsonElement build)
    {
        string? cloud = null, environment = null, appType = null, appName = null, branch = null;
        if (build.TryGetProperty("tags", out var tags) && tags.ValueKind == JsonValueKind.Array)
        {
            foreach (var tag in tags.EnumerateArray())
            {
                if (tag.GetString() is not { } t) continue;
                if (t.StartsWith(TagCloudPrefix)) cloud = t[TagCloudPrefix.Length..];
                else if (t.StartsWith(TagEnvironmentPrefix)) environment = t[TagEnvironmentPrefix.Length..];
                else if (t.StartsWith("epicAppType.")) appType = t["epicAppType.".Length..];
                else if (t.StartsWith(TagAppNamePrefix)) appName = t[TagAppNamePrefix.Length..];
                else if (t.StartsWith(TagBranchPrefix)) branch = Uri.UnescapeDataString(t[TagBranchPrefix.Length..]);
            }
        }
        return (cloud, environment, appType, appName, branch);
    }

    public async Task<List<AdoPipelineRun>> GetRunsForAppAsync(string repo, int? afterBuildId = null, int top = 20, CancellationToken ct = default)
    {
        // One API call — filter by repo tag
        var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{repo}")}&$top={top}&queryOrder=queueTimeDescending&api-version=7.1";
        var buildsJson = await CallApiAsync(url, ct);

        if (buildsJson is null) return [];

        var results = new List<AdoPipelineRun>();

        foreach (var build in buildsJson.Value.GetProperty(PropValue).EnumerateArray())
        {
            var buildId = build.GetProperty("id").GetInt32();

            // Skip builds we already have (everything at or before afterBuildId)
            if (afterBuildId.HasValue && buildId <= afterBuildId.Value)
                continue;

            var adoStatus = build.TryGetProperty(PropStatus, out var st) ? st.GetString() : UnknownStatus;
            var adoResult = build.TryGetProperty(PropResult, out var res) ? res.GetString() : null;
            var status = MapRunStatus(adoStatus, adoResult);

            var triggeredBy = ResolveTriggeredBy(build);

            var (branch, environment) = ResolveBranchAndEnvironment(build);

            var startedAt = ParseStartTime(build);

            var finishedAt = ParseOptionalTime(build, PropFinishTime);

            var duration = finishedAt.HasValue
                ? FormatDuration(finishedAt.Value - startedAt)
                : null;

            // Get stage-level results from the timeline
            var stages = await GetStageResultsAsync(buildId, isTerminal: status != StatusRunning, ct);

            results.Add(new AdoPipelineRun
            {
                Id = buildId,
                Status = status,
                TriggeredBy = triggeredBy,
                Branch = branch,
                Environment = environment,
                StartedAt = startedAt,
                Duration = duration,
                Stages = stages
            });
        }

        // Resolve real triggeredBy from orchestrator pipeline
        await ResolveTriggeredByFromOrchestratorAsync(repo, results, ct);

        return results;
    }

    /// <summary>
    /// Lightweight bulk fetch of recent runs for an app — same shape as GetRunsForAppAsync
    /// but without per-run timeline calls (no stage-level data). Used by the main page
    /// refresh, which only needs Status to compute the success rate and the latest run's
    /// triggeredBy/branch/environment for the row display.
    /// Cost: 2 ADO calls per app (1 builds list + 1 orchestrator triggeredBy resolve),
    /// regardless of how many runs are returned.
    /// </summary>
    public async Task<List<AdoLatestRun>> GetRecentRunsForAppAsync(string repo, int top = 20, CancellationToken ct = default)
    {
        var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{repo}")}&$top={top}&queryOrder=queueTimeDescending&api-version=7.1";
        var buildsJson = await CallApiAsync(url, ct);

        if (buildsJson is null) return [];

        var results = new List<AdoLatestRun>();

        foreach (var build in buildsJson.Value.GetProperty(PropValue).EnumerateArray())
        {
            var adoStatus = build.TryGetProperty(PropStatus, out var st) ? st.GetString() : UnknownStatus;
            var adoResult = build.TryGetProperty(PropResult, out var res) ? res.GetString() : null;

            var triggeredBy = ResolveTriggeredBy(build);

            var (branch, environment) = ResolveBranchAndEnvironment(build);

            var startedAt = ParseStartTime(build);

            var finishedAt = ParseOptionalTime(build, PropFinishTime);

            var tags = ReadEpicTags(build);

            results.Add(new AdoLatestRun
            {
                Id = build.GetProperty("id").GetInt32(),
                Status = MapRunStatus(adoStatus, adoResult),
                TriggeredBy = triggeredBy,
                Branch = branch,
                Environment = tags.Environment ?? environment,
                Cloud = tags.Cloud,
                AppType = tags.AppType,
                AppName = tags.AppName,
                StartedAt = startedAt,
                Duration = finishedAt.HasValue ? FormatDuration(finishedAt.Value - startedAt) : null
            });
        }

        // Resolve real triggeredBy from orchestrator pipeline (single bulk call)
        var orchRuns = await ResolveTriggeredByFromOrchestratorAsync(repo, results, ct);

        // Include unmatched orchestrators so the main table shows StatusRunning during prepare
        // Ignore succeeded orchestrators with no engine after 5 minutes (stale/orphaned)
        var now = DateTime.UtcNow;
        foreach (var orch in orchRuns.Where(o => !o.Matched && !(o.Status == RunStatus.Success && o.FinishTime.HasValue && (now - o.FinishTime.Value).TotalMinutes > 2)))
        {
            results.Add(new AdoLatestRun
            {
                Id = orch.Id,
                Status = orch.Status == RunStatus.Failed ? StatusFailed : StatusRunning,
                TriggeredBy = orch.RequestedFor ?? SystemActor,
                Branch = orch.Branch,
                Environment = orch.Environment,
                Cloud = null,
                AppType = null,
                AppName = null,
                StartedAt = orch.StartedAt,
                Duration = orch.FinishTime.HasValue ? FormatDuration(orch.FinishTime.Value - orch.StartedAt) : null
            });
        }

        return results;
    }

    /// <summary>
    /// Counts ALL completed runs for an app — total and successful — by paginating
    /// through every build with the appName tag. In-progress runs are excluded by
    /// the server-side statusFilter, so the totals reflect lifetime success rate.
    /// Cost: 1 ADO call per 1000 runs (typically just 1).
    /// </summary>
    public async Task<(int Total, int Successful, TimeSpan TotalDuration)> GetCompletedRunCountsAsync(string repo, CancellationToken ct = default)
    {
        var total = 0;
        var successful = 0;
        var totalDuration = TimeSpan.Zero;
        string? continuationToken = null;
        const int pageSize = 1000;

        do
        {
            var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{repo}")}&statusFilter=completed&$top={pageSize}&queryOrder=queueTimeDescending&api-version=7.1";
            if (continuationToken is not null)
                url += $"&continuationToken={Uri.EscapeDataString(continuationToken)}";

            var (json, nextToken) = await CallApiWithContinuationAsync(url, ct);
            if (json is null) break;

            foreach (var build in json.Value.GetProperty(PropValue).EnumerateArray())
                TallyCompletedBuild(build, ref total, ref successful, ref totalDuration);

            continuationToken = nextToken;
        } while (!string.IsNullOrEmpty(continuationToken));

        return (total, successful, totalDuration);
    }

    // Folds one completed build into the running totals: canceled builds don't
    // count; succeeded ones bump the success tally; elapsed time is summed when
    // both start and finish are known.
    private static void TallyCompletedBuild(JsonElement build, ref int total, ref int successful, ref TimeSpan totalDuration)
    {
        var result = build.TryGetProperty(PropResult, out var r) ? r.GetString() : null;
        if (result == "canceled") return;
        total++;
        if (result == "succeeded") successful++;

        var startedAt = ParseOptionalTime(build, PropStartTime);
        var finishedAt = ParseOptionalTime(build, PropFinishTime);
        if (startedAt.HasValue && finishedAt.HasValue)
            totalDuration += finishedAt.Value - startedAt.Value;
    }

    /// <summary>
    /// Counts ALL runs for an app (any status, including in-progress) by paginating
    /// through every build with the appName tag. Used to compute the pagination total
    /// for the manage modal's runs table.
    /// </summary>
    public async Task<int> GetTotalRunCountAsync(string repo, CancellationToken ct = default)
    {
        var cacheKey = $"runcount:{repo}";
        if (cache.TryGetValue(cacheKey, out int cached))
            return cached;

        var total = 0;
        string? continuationToken = null;
        const int pageSize = 1000;

        do
        {
            var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{repo}")}&$top={pageSize}&queryOrder=queueTimeDescending&api-version=7.1";
            if (continuationToken is not null)
                url += $"&continuationToken={Uri.EscapeDataString(continuationToken)}";

            var (json, nextToken) = await CallApiWithContinuationAsync(url, ct);
            if (json is null) break;

            total += json.Value.GetProperty(PropValue).GetArrayLength();
            continuationToken = nextToken;
        } while (!string.IsNullOrEmpty(continuationToken));

        cache.Set(cacheKey, total, new MemoryCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TotalCountCacheTtl,
            Size = 1
        });

        return total;
    }

    /// <summary>
    /// Server-side paged fetch of runs for an app. Walks ADO continuation tokens to
    /// reach the requested page, then fetches per-build timelines and orchestrator
    /// triggeredBy only for that page. Total count comes from a parallel
    /// GetTotalRunCountAsync call.
    /// </summary>
    public async Task<AdoRunsPage> GetRunsPageAsync(string repo, int page, int pageSize, CancellationToken ct = default)
    {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 20;

        // Kick off the total count in parallel — it's an independent set of calls.
        var totalTask = GetTotalRunCountAsync(repo, ct);

        var pageJson = await WalkToPageAsync(repo, page, pageSize, ct);

        var results = new List<AdoPipelineRun>();
        if (pageJson is not null)
        {
            foreach (var build in pageJson.Value.GetProperty(PropValue).EnumerateArray())
                results.Add(await MapBuildToRunAsync(build, includeStages: true, ct));

            var orchRuns = await ResolveTriggeredByFromOrchestratorAsync(repo, results, ct);

            // Include unmatched failed/running orchestrators as standalone "Prepare" entries
            if (page == 1)
            {
                results.AddRange(UnmatchedOrchestrators(orchRuns).Select(BuildPrepareRow));
                results = results.OrderByDescending(r => r.StartedAt).ToList();
            }
        }

        var total = await totalTask;

        return new AdoRunsPage { Total = total, Runs = results };
    }

    // Walks ADO continuation tokens until the requested page, returning its JSON
    // (or null if there are fewer pages than requested).
    private async Task<JsonElement?> WalkToPageAsync(string repo, int page, int pageSize, CancellationToken ct)
    {
        string? continuationToken = null;
        for (var i = 1; i <= page; i++)
        {
            var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{repo}")}&$top={pageSize}&queryOrder=queueTimeDescending&api-version=7.1";
            if (continuationToken is not null)
                url += $"&continuationToken={Uri.EscapeDataString(continuationToken)}";

            var (json, nextToken) = await CallApiWithContinuationAsync(url, ct);
            if (json is null) return null;
            if (i == page) return json;
            if (string.IsNullOrEmpty(nextToken)) return null; // asked beyond the end
            continuationToken = nextToken;
        }
        return null;
    }

    // Orchestrators with no matching engine run that should still surface as a
    // "Prepare"-phase row: excludes ones that succeeded and finished >2 min ago
    // (stale/orphaned — the engine run is just late to appear).
    private static IEnumerable<OrchestratorInfo> UnmatchedOrchestrators(List<OrchestratorInfo> orchRuns)
    {
        var now = DateTime.UtcNow;
        return orchRuns
            .Where(o => !o.Matched)
            .Where(o => !(o.Status == RunStatus.Success && o.FinishTime.HasValue && (now - o.FinishTime.Value).TotalMinutes > 2));
    }

    // Builds the standalone "Prepare"-phase run row shown while an orchestrator
    // has been triggered but its engine build hasn't appeared yet.
    private static AdoPipelineRun BuildPrepareRow(OrchestratorInfo orch) => new()
    {
        Id = orch.Id,
        OrchestratorId = orch.Id,
        // Failed if the orchestrator failed, otherwise Running (still preparing, or
        // succeeded but the engine hasn't started yet).
        Status = orch.Status == RunStatus.Failed ? StatusFailed : StatusRunning,
        TriggeredBy = orch.RequestedFor ?? SystemActor,
        Branch = orch.Branch,
        Environment = orch.Environment,
        StartedAt = orch.StartedAt,
        Duration = null,
        Stages = new PipelineStages
        {
            Prepare = orch.Status,
            Download = orch.Status == RunStatus.Success ? RunStatus.Running : RunStatus.Skipped,
            Review = RunStatus.Skipped,
            Build = RunStatus.Skipped,
            Test = RunStatus.Skipped,
            Scan = RunStatus.Skipped,
            InfraDeploy = RunStatus.Skipped,
            AppDeploy = RunStatus.Skipped,
            IntegrationTest = RunStatus.Skipped
        }
    };

    private async Task<AdoPipelineRun> MapBuildToRunAsync(JsonElement build, bool includeStages, CancellationToken ct)
    {
        var buildId = build.GetProperty("id").GetInt32();

        var adoStatus = build.TryGetProperty(PropStatus, out var st) ? st.GetString() : UnknownStatus;
        var adoResult = build.TryGetProperty(PropResult, out var res) ? res.GetString() : null;
        var status = MapRunStatus(adoStatus, adoResult);

        var triggeredBy = ResolveTriggeredBy(build);

        var (branch, environment) = ResolveBranchAndEnvironment(build);

        var startedAt = ParseStartTime(build);

        var finishedAt = ParseOptionalTime(build, PropFinishTime);

        var duration = finishedAt.HasValue ? FormatDuration(finishedAt.Value - startedAt) : null;

        var stages = includeStages
            ? await GetStageResultsAsync(buildId, isTerminal: status != StatusRunning, ct)
            : new PipelineStages
            {
                Prepare = RunStatus.Success,
                Download = RunStatus.Success,
                Review = RunStatus.Skipped,
                Build = RunStatus.Skipped,
                Test = RunStatus.Skipped,
                Scan = RunStatus.Skipped,
                InfraDeploy = RunStatus.Skipped,
                AppDeploy = RunStatus.Skipped,
                IntegrationTest = RunStatus.Skipped
            };

        var tags = ReadEpicTags(build);

        return new AdoPipelineRun
        {
            Id = buildId,
            Status = status,
            TriggeredBy = triggeredBy,
            Branch = branch,
            Environment = tags.Environment ?? environment,
            Cloud = tags.Cloud,
            AppName = tags.AppName,
            StartedAt = startedAt,
            Duration = duration,
            Stages = stages
        };
    }

    // Sentinel default of the orchestrator's "triggeredBy" parameter. ADO won't enable
    // Run on a blank field, so a manual run leaves this placeholder rather than empty.
    private const string TriggeredByAuto = "auto";

    /// <summary>
    /// Resolves the triggering user for a build from the EPIC-supplied <c>triggeredBy</c>
    /// template parameter — set by the orchestrator to the real portal user (or, for a
    /// direct ADO run, resolved from <c>Build.RequestedFor</c>) and carried through to the
    /// engine.
    /// <para>
    /// ADO's own <c>requestedFor</c> is deliberately NOT used as a fallback: EPIC queues
    /// runs via a PAT, so on those builds it is always the token owner rather than the real
    /// user. Any build without a real <c>triggeredBy</c> value — runs predating this
    /// parameter, or the orchestrator build during its brief Prepare phase before the engine
    /// build exists — reports SystemActor.
    /// </para>
    /// </summary>
    private static string ResolveTriggeredBy(JsonElement build)
    {
        if (build.TryGetProperty(PropTemplateParameters, out var tp) && tp.ValueKind == JsonValueKind.Object
            && tp.TryGetProperty("triggeredBy", out var tb) && tb.ValueKind == JsonValueKind.String)
        {
            var value = tb.GetString();
            if (!string.IsNullOrWhiteSpace(value) && value != TriggeredByAuto) return value;
        }

        return SystemActor;
    }

    /// <summary>
    /// Queries orchestrator builds (tagged with appName) and matches each engine run
    /// to its orchestrator run by time proximity, setting the Prepare stage status from
    /// the orchestrator's result. (TriggeredBy is resolved directly from each engine
    /// build's template parameters — see <see cref="ResolveTriggeredBy"/>.)
    /// </summary>
    private Task<List<OrchestratorInfo>> ResolveTriggeredByFromOrchestratorAsync(string appName, List<AdoPipelineRun> engineRuns, CancellationToken ct) =>
        ResolveTriggeredByFromOrchestratorCoreAsync(
            appName,
            engineRuns.Count,
            engineRuns.Select<AdoPipelineRun, (int Id, DateTime StartedAt, Action<string> SetTriggeredBy, Action<RunStatus>? SetPrepare, Action<int>? SetOrchestratorId)>(
                r => (r.Id, r.StartedAt, s => r.TriggeredBy = s, s => r.Stages.Prepare = s, id => r.OrchestratorId = id)).ToList(),
            ct);

    private Task<List<OrchestratorInfo>> ResolveTriggeredByFromOrchestratorAsync(string appName, List<AdoLatestRun> engineRuns, CancellationToken ct) =>
        ResolveTriggeredByFromOrchestratorCoreAsync(
            appName,
            engineRuns.Count,
            engineRuns.Select<AdoLatestRun, (int Id, DateTime StartedAt, Action<string> SetTriggeredBy, Action<RunStatus>? SetPrepare, Action<int>? SetOrchestratorId)>(
                r => (r.Id, r.StartedAt, s => r.TriggeredBy = s, null, null)).ToList(),
            ct);

    // The orchestrator tags itself with epicEngineId.<engineBuildId> after it
    // triggers the engine, giving a deterministic engine↔orchestrator link
    // (see epic-orchestrator.yml). Returns the engine build id, or null.
    private static int? ParseEngineIdTag(JsonElement build)
    {
        if (build.TryGetProperty("tags", out var tags) && tags.ValueKind == JsonValueKind.Array)
        {
            foreach (var tag in tags.EnumerateArray())
            {
                if (tag.GetString() is { } t && t.StartsWith("epicEngineId.", StringComparison.Ordinal)
                    && int.TryParse(t.AsSpan("epicEngineId.".Length), out var eid))
                    return eid;
            }
        }
        return null;
    }

    // Maps an orchestrator build JSON element to an OrchestratorInfo.
    private OrchestratorInfo MapOrchestratorInfo(JsonElement b)
    {
        var adoStatus = b.TryGetProperty(PropStatus, out var statusProp) ? statusProp.GetString() : UnknownStatus;
        var adoResult = b.TryGetProperty(PropResult, out var resProp) ? resProp.GetString() : null;
        var (branch, environment) = ResolveBranchAndEnvironment(b);

        return new OrchestratorInfo
        {
            Id = b.GetProperty("id").GetInt32(),
            FinishTime = ParseOptionalTime(b, PropFinishTime),
            StartedAt = ParseStartTime(b),
            RequestedFor = ResolveTriggeredBy(b),
            Status = MapStageStatus(adoStatus, adoResult),
            Branch = branch,
            Environment = environment,
            EngineId = ParseEngineIdTag(b),
            Matched = false
        };
    }

    private async Task<List<OrchestratorInfo>> ResolveTriggeredByFromOrchestratorCoreAsync(
        string appName,
        int totalRuns,
        List<(int Id, DateTime StartedAt, Action<string> SetTriggeredBy, Action<RunStatus>? SetPrepare, Action<int>? SetOrchestratorId)> engineRuns,
        CancellationToken ct)
    {
        var url = $"{BaseUrl}/build/builds?definitions={OrchestratorPipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{appName}")}&$top={Math.Max(totalRuns + 5, 20)}&queryOrder=queueTimeDescending&api-version=7.1";
        var json = await CallApiAsync(url, ct);
        if (json is null) return [];

        var orchRuns = json.Value.GetProperty(PropValue).EnumerateArray()
            .Select(MapOrchestratorInfo)
            .ToList();

        if (orchRuns.Count == 0 || engineRuns.Count == 0) return orchRuns;

        // Pass 1 — exact links via the epicEngineId tag the orchestrator stamps on itself.
        // Deterministic and immune to two runs of the same app overlapping. Claim these
        // first so a tagless time-fallback can't steal an orchestrator that a later engine
        // run owns by tag.
        var linked = new HashSet<int>();
        for (var i = 0; i < engineRuns.Count; i++)
        {
            var run = engineRuns[i];
            var match = orchRuns.FirstOrDefault(o => !o.Matched && o.EngineId == run.Id);
            if (match is not null)
            {
                Apply(run, match);
                linked.Add(i);
            }
        }

        // Pass 2 — time-proximity fallback for engine runs not linked by tag (e.g. runs
        // that predate the orchestrator emitting the epicEngineId tag).
        for (var i = 0; i < engineRuns.Count; i++)
        {
            if (linked.Contains(i)) continue;
            var match = FindTimeProximityMatch(orchRuns, engineRuns[i].StartedAt);
            if (match is not null) Apply(engineRuns[i], match);
        }

        return orchRuns;

        void Apply((int Id, DateTime StartedAt, Action<string> SetTriggeredBy, Action<RunStatus>? SetPrepare, Action<int>? SetOrchestratorId) run, OrchestratorInfo match)
        {
            match.Matched = true;
            // The engine build already carries triggeredBy directly; only let the
            // orchestrator override when it knows a real user, so a SystemActor default
            // never clobbers a good engine value.
            if (!string.IsNullOrEmpty(match.RequestedFor) && match.RequestedFor != SystemActor)
                run.SetTriggeredBy(match.RequestedFor);
            run.SetPrepare?.Invoke(match.Status);
            run.SetOrchestratorId?.Invoke(match.Id);
        }
    }

    // The unclaimed orchestrator that best matches an engine run's start time:
    // a finished one closest before (engineStart + 5 min), else a still-running
    // one started within the 5 min before the engine.
    private static OrchestratorInfo? FindTimeProximityMatch(List<OrchestratorInfo> orchRuns, DateTime engineStartedAt)
    {
        var match = orchRuns
            .Where(o => !o.Matched && o.FinishTime.HasValue && o.FinishTime.Value <= engineStartedAt.AddMinutes(5))
            .MinBy(o => engineStartedAt - o.FinishTime!.Value);

        match ??= orchRuns
            .Where(o => !o.Matched && !o.FinishTime.HasValue && o.StartedAt <= engineStartedAt && (engineStartedAt - o.StartedAt).TotalMinutes <= 5)
            .MinBy(o => engineStartedAt - o.StartedAt);

        return match;
    }

    private sealed class OrchestratorInfo
    {
        public int Id { get; set; }
        public DateTime? FinishTime { get; set; }
        public DateTime StartedAt { get; set; }
        public string? RequestedFor { get; set; }
        public RunStatus Status { get; set; }
        public string Branch { get; set; } = "";
        public string Environment { get; set; } = DefaultEnvironment;
        public int? EngineId { get; set; }
        public bool Matched { get; set; }
    }

    private async Task<JsonElement?> GetTimelineJsonAsync(int buildId, bool isTerminal, CancellationToken ct)
    {
        var cacheKey = $"timeline-raw:{buildId}";
        if (isTerminal && cache.TryGetValue(cacheKey, out JsonElement cachedRaw))
            return cachedRaw;

        var url = $"{BaseUrl}/build/builds/{buildId}/timeline?api-version=7.1";
        var json = await CallApiAsync(url, ct);

        if (json is not null && isTerminal)
        {
            cache.Set(cacheKey, json.Value, new MemoryCacheEntryOptions
            {
                SlidingExpiration = TimelineCacheTtl,
                Size = 1
            });
        }

        return json;
    }

    private async Task<PipelineStages> GetStageResultsAsync(int buildId, bool isTerminal, CancellationToken ct)
    {
        var cacheKey = $"timeline:{buildId}";
        if (isTerminal && cache.TryGetValue(cacheKey, out PipelineStages? cached) && cached is not null)
            return cached;

        var timelineJson = await GetTimelineJsonAsync(buildId, isTerminal, ct);
        if (timelineJson is null) return NewSkippedStages();

        var stages = ParseStagesFromTimeline(timelineJson.Value);

        if (isTerminal)
        {
            ReconcileTerminalStages(stages);
            cache.Set(cacheKey, stages, new MemoryCacheEntryOptions
            {
                SlidingExpiration = TimelineCacheTtl,
                Size = 1
            });
        }

        return stages;
    }

    // Default stage set: Prepare+Download assumed done, everything else Skipped
    // until the timeline says otherwise.
    private static PipelineStages NewSkippedStages() => new()
    {
        Prepare = RunStatus.Success,
        Download = RunStatus.Success,
        Review = RunStatus.Skipped,
        Build = RunStatus.Skipped,
        Test = RunStatus.Skipped,
        Scan = RunStatus.Skipped,
        InfraDeploy = RunStatus.Skipped,
        AppDeploy = RunStatus.Skipped,
        IntegrationTest = RunStatus.Skipped
    };

    // Reads the "Stage" records out of a timeline into a PipelineStages set.
    private static PipelineStages ParseStagesFromTimeline(JsonElement timelineJson)
    {
        var stages = NewSkippedStages();
        foreach (var record in timelineJson.GetProperty("records").EnumerateArray())
        {
            if ((record.TryGetProperty("type", out var t) ? t.GetString() : null) != "Stage") continue;

            var name = record.TryGetProperty("name", out var n) ? n.GetString() : null;
            var state = record.TryGetProperty("state", out var s) ? s.GetString() : null;
            var result = record.TryGetProperty(PropResult, out var r) ? r.GetString() : null;
            ApplyStageStatus(stages, name, MapStageStatus(state, result));
        }
        return stages;
    }

    // Assigns a stage-timeline record's status to the matching PipelineStages slot
    // (tolerant of both the engine's and the legacy stage display names).
    private static void ApplyStageStatus(PipelineStages stages, string? name, RunStatus status)
    {
        switch (name)
        {
            case "Download" or "Download Source": stages.Download = status; break;
            case "Review" or "Review App": stages.Review = status; break;
            case "Build" or "Build App": stages.Build = status; break;
            case "BuildTest" or "UnitTest" or "Build Tests" or "Unit Tests": stages.Test = status; break;
            case "Scan" or "Scan App": stages.Scan = status; break;
            case "DeployInfra" or "Deploy Infrastructure": stages.InfraDeploy = status; break;
            case "Deploy" or "Deploy App": stages.AppDeploy = status; break;
            case "IntegrationTest" or "Integration Tests": stages.IntegrationTest = status; break;
        }
    }

    // When the run is terminal, ADO may leave stages inProgress/pending (e.g. a
    // failed stage canceling the run mid-flight). Correct these so the UI doesn't
    // show blue/hollow dots on a completed run.
    private static void ReconcileTerminalStages(PipelineStages stages)
    {
        stages.Download = ReconcileTerminalStage(stages.Download);
        stages.Review = ReconcileTerminalStage(stages.Review);
        stages.Build = ReconcileTerminalStage(stages.Build);
        stages.Test = ReconcileTerminalStage(stages.Test);
        stages.Scan = ReconcileTerminalStage(stages.Scan);
        stages.InfraDeploy = ReconcileTerminalStage(stages.InfraDeploy);
        stages.AppDeploy = ReconcileTerminalStage(stages.AppDeploy);
        stages.IntegrationTest = ReconcileTerminalStage(stages.IntegrationTest);
    }

    private static RunStatus ReconcileTerminalStage(RunStatus status) => status switch
    {
        RunStatus.Running => RunStatus.Canceled,
        RunStatus.Pending => RunStatus.Skipped,
        _ => status
    };

    public async Task<StageDetail?> GetStageDetailAsync(int buildId, string stageName, CancellationToken ct = default)
    {
        var timelineJson = await GetTimelineJsonAsync(buildId, isTerminal: false, ct);
        if (timelineJson is null) return null;

        var records = timelineJson.Value.GetProperty("records");
        var (byId, childrenOf) = IndexTimelineRecords(records);

        var stageRecord = FindStageRecord(records, stageName);
        if (stageRecord is null) return null;

        var stageId = stageRecord.Value.GetProperty("id").GetString()!;
        var steps = CollectDescendants(stageId, childrenOf)
            .Where(byId.ContainsKey)
            .Select(id => byId[id])
            .Where(r => (r.TryGetProperty("type", out var t) ? t.GetString() : null) == "Task")
            .Select(BuildStep)
            .OrderBy(e => e.Order)
            .Select(e => e.Step)
            .ToList();

        var stageState = stageRecord.Value.TryGetProperty("state", out var ss) ? ss.GetString() : null;
        var stageResult = stageRecord.Value.TryGetProperty(PropResult, out var sr) ? sr.GetString() : null;
        var stageStatus = MapStageStatus(stageState, stageResult);
        var stageDuration = ComputeDuration(stageRecord.Value);

        // Wrap steps in a single synthetic job (the frontend flattens jobs→steps anyway)
        return new StageDetail
        {
            StageName = stageName,
            Status = stageStatus,
            Duration = stageDuration,
            Jobs = [new StageJob { Name = "Steps", Status = stageStatus, Duration = stageDuration, Steps = steps }]
        };
    }

    // Indexes timeline records by id and builds a parent→children id lookup.
    private static (Dictionary<string, JsonElement> ById, Dictionary<string, List<string>> ChildrenOf) IndexTimelineRecords(JsonElement records)
    {
        var byId = new Dictionary<string, JsonElement>();
        var childrenOf = new Dictionary<string, List<string>>();
        foreach (var record in records.EnumerateArray())
        {
            if ((record.TryGetProperty("id", out var idProp) ? idProp.GetString() : null) is not { } id)
                continue;
            byId[id] = record;
            if ((record.TryGetProperty("parentId", out var p) ? p.GetString() : null) is { } parentId)
            {
                if (!childrenOf.TryGetValue(parentId, out var list)) childrenOf[parentId] = list = [];
                list.Add(id);
            }
        }
        return (byId, childrenOf);
    }

    // First "Stage" record whose name matches the requested stage, or null.
    private static JsonElement? FindStageRecord(JsonElement records, string stageName)
    {
        foreach (var record in records.EnumerateArray())
        {
            if ((record.TryGetProperty("type", out var t) ? t.GetString() : null) != "Stage")
                continue;
            var name = record.TryGetProperty("name", out var n) ? n.GetString() : null;
            if (MatchesStageName(name, stageName))
                return record;
        }
        return null;
    }

    // Breadth-first walk of all descendant ids under a stage (Phase/Job/Task).
    private static HashSet<string> CollectDescendants(string stageId, Dictionary<string, List<string>> childrenOf)
    {
        var descendants = new HashSet<string>();
        var queue = new Queue<string>();
        queue.Enqueue(stageId);
        while (queue.Count > 0)
        {
            if (!childrenOf.TryGetValue(queue.Dequeue(), out var children)) continue;
            foreach (var childId in children)
                if (descendants.Add(childId)) queue.Enqueue(childId);
        }
        return descendants;
    }

    // Maps a Task timeline record to a StageStep (with its sort order).
    private static (int Order, StageStep Step) BuildStep(JsonElement record)
    {
        int? logId = record.TryGetProperty("log", out var logProp)
            && logProp.ValueKind == JsonValueKind.Object
            && logProp.TryGetProperty("id", out var logIdProp)
            ? logIdProp.GetInt32() : null;

        var order = record.TryGetProperty("order", out var o) ? o.GetInt32() : 0;

        return (order, new StageStep
        {
            Name = record.TryGetProperty("name", out var n) ? n.GetString() ?? "Step" : "Step",
            Status = MapStageStatus(
                record.TryGetProperty("state", out var s) ? s.GetString() : null,
                record.TryGetProperty(PropResult, out var r) ? r.GetString() : null),
            Duration = ComputeDuration(record),
            LogId = logId
        });
    }

    public async Task<string?> GetStepLogAsync(int buildId, int logId, CancellationToken ct = default)
    {
        var url = $"{BaseUrl}/build/builds/{buildId}/logs/{logId}?api-version=7.1";

        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        var credentials = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{Pat}"));
        request.Headers.Authorization = new AuthenticationHeaderValue(BasicScheme, credentials);

        var response = await httpClient.SendAsync(request, ct);
        if (!response.IsSuccessStatusCode)
        {
            logger.LogWarning("ADO Logs API returned {StatusCode} for build {BuildId} log {LogId}", (int)response.StatusCode, buildId, logId);
            return null;
        }

        var body = await response.Content.ReadAsStringAsync(ct);
        return NormalizeStepLog(body);
    }

    // The ADO Logs API returns the log as a JSON envelope — {"count":N,"value":
    // ["line 1","line 2",...]} — because the shared HttpClient sends
    // Accept: application/json (a 429 mitigation, see Program.cs). Left raw, that
    // envelope renders as a single unreadable line in the UI. Flatten the "value"
    // array back into newline-joined text. Falls back to the raw body if the
    // response isn't the expected JSON shape (e.g. a plain-text log).
    private static string NormalizeStepLog(string body)
    {
        if (string.IsNullOrEmpty(body)) return body;

        try
        {
            using var doc = System.Text.Json.JsonDocument.Parse(body);
            if (doc.RootElement.ValueKind == JsonValueKind.Object
                && doc.RootElement.TryGetProperty(PropValue, out var value)
                && value.ValueKind == JsonValueKind.Array)
            {
                return string.Join('\n', value.EnumerateArray()
                    .Where(l => l.ValueKind == JsonValueKind.String)
                    .Select(l => l.GetString()));
            }
        }
        catch (System.Text.Json.JsonException)
        {
            // Not JSON — return the body as-is.
        }

        return body;
    }

    // Matches the SonarQube dashboard URL that SonarQubeAnalyze prints on success:
    //   "ANALYSIS SUCCESSFUL, you can find the results at: https://.../dashboard?id=..."
    // Only SonarQube emits this line — Wiz produces no such URL — so a match also
    // confirms the scan tool, keeping the "SonarQube only" condition server-side.
    //
    // The URL char class stops at whitespace, quote, or backslash. The ADO logs
    // endpoint returns the log as a JSON array of strings, so the raw body reads
    // ...dashboard?id=x&branch=main","<next-line>". A greedy \S+ would eat across
    // the "," JSON delimiter into the following line; excluding " and \ stops the
    // capture at the true end of the URL. (Real dashboard URLs contain none of these.)
    private static readonly System.Text.RegularExpressions.Regex SonarResultUrlRegex =
        new(@"you can find the results at:\s*(?<url>https?://[^\s""\\]+)",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase | System.Text.RegularExpressions.RegexOptions.Compiled,
            TimeSpan.FromSeconds(2));

    // Extracts the SonarQube dashboard URL from the Scan stage's "Analyze code"
    // step log. Returns null when the scan wasn't SonarQube, the step/log is
    // absent, or no URL line was printed (e.g. a failed or non-terminal scan).
    public async Task<string?> GetScanResultUrlAsync(int buildId, CancellationToken ct = default)
    {
        var detail = await GetStageDetailAsync(buildId, "scan", ct);
        if (detail is null) return null;

        // The SonarQubeAnalyze task's displayName is "Analyze code" (scan.yml).
        var analyzeStep = detail.Jobs
            .SelectMany(j => j.Steps)
            .FirstOrDefault(s => s.LogId is not null
                && string.Equals(s.Name, "Analyze code", StringComparison.OrdinalIgnoreCase));
        if (analyzeStep?.LogId is null) return null;

        var log = await GetStepLogAsync(buildId, analyzeStep.LogId.Value, ct);
        if (string.IsNullOrEmpty(log)) return null;

        var match = SonarResultUrlRegex.Match(log);
        return match.Success ? match.Groups["url"].Value : null;
    }

    // Fetches the Markdown compliance report published by the Review stage.
    // Returns null if the artifact or a .md entry doesn't exist (e.g. the run
    // predates the Review stage).
    public async Task<string?> GetComplianceReportAsync(int buildId, CancellationToken ct = default)
        => await ReadComplianceArtifactEntryAsync(buildId, ".md", ct);

    // Fetches the structured JSON compliance report published by the Review
    // stage and reshapes it into the summary the dashboard renders (tool version
    // + verdict counts). Returns null if the artifact/.json entry doesn't exist
    // or cannot be parsed (e.g. a run that predates the JSON output).
    public async Task<ComplianceSummary?> GetComplianceSummaryAsync(int buildId, CancellationToken ct = default)
        => (await GetComplianceReportJsonAsync(buildId, ct))?.Summary;

    // Fetches and parses the full structured JSON compliance report (summary +
    // app profile + per-control findings) so the dashboard can render it
    // natively. Returns null if the artifact/.json entry doesn't exist or cannot
    // be parsed (e.g. a run that predates the JSON output).
    public async Task<ComplianceReport?> GetComplianceReportJsonAsync(int buildId, CancellationToken ct = default)
    {
        var json = await ReadComplianceArtifactEntryAsync(buildId, ".json", ct);
        if (json is null) return null;

        try
        {
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;
            return new ComplianceReport
            {
                Summary = ParseComplianceSummary(root),
                Profile = ParseComplianceProfile(root),
                Findings = ParseComplianceFindings(root),
            };
        }
        catch (JsonException ex)
        {
            logger.LogWarning(ex, "Compliance JSON report for build {BuildId} could not be parsed", buildId);
            return null;
        }
    }

    private static ComplianceSummary ParseComplianceSummary(JsonElement root)
    {
        var metadata = root.TryGetProperty("metadata", out var m) ? m : default;
        var summaryEl = root.TryGetProperty("summary", out var s) ? s : default;

        var counts = new Dictionary<string, int>();
        if (summaryEl.ValueKind == JsonValueKind.Object &&
            summaryEl.TryGetProperty("byVerdict", out var by) && by.ValueKind == JsonValueKind.Object)
        {
            foreach (var prop in by.EnumerateObject())
                counts[prop.Name] = prop.Value.GetInt32();
        }

        return new ComplianceSummary
        {
            Tool = GetStringOrNull(metadata, "tool"),
            Version = GetStringOrNull(metadata, "version"),
            SpecSource = GetStringOrNull(metadata, "specSource"),
            ScannedAt = GetStringOrNull(metadata, "scannedAt"),
            Total = summaryEl.ValueKind == JsonValueKind.Object && summaryEl.TryGetProperty("total", out var t) ? t.GetInt32() : 0,
            ByVerdict = counts,
        };
    }

    private static ComplianceProfile? ParseComplianceProfile(JsonElement root)
    {
        if (!root.TryGetProperty("profile", out var p) || p.ValueKind != JsonValueKind.Object)
            return null;
        return new ComplianceProfile
        {
            Kinds = GetStringListOrNull(p, "kinds"),
            AuthModel = GetStringOrNull(p, "authModel"),
            Idp = GetStringOrNull(p, "idp"),
            Narrative = GetStringOrNull(p, "narrative"),
        };
    }

    private static List<ComplianceFinding> ParseComplianceFindings(JsonElement root)
    {
        var findings = new List<ComplianceFinding>();
        if (!root.TryGetProperty("findings", out var fs) || fs.ValueKind != JsonValueKind.Array)
            return findings;

        foreach (var f in fs.EnumerateArray())
        {
            var control = f.TryGetProperty("control", out var c) ? c : default;
            findings.Add(new ComplianceFinding
            {
                NistId = GetStringOrNull(control, "nistId") ?? "",
                Title = GetStringOrNull(control, "title"),
                Requirement = GetStringOrNull(control, "requirement"),
                Verdict = GetStringOrNull(f, "verdict") ?? "",
                Kind = GetStringOrNull(f, "kind"),
                Severity = GetStringOrNull(f, "severity"),
                Message = GetStringOrNull(f, "message"),
                Remediation = GetStringOrNull(f, "remediation"),
                InheritedFrom = GetStringOrNull(f, "inheritedFrom"),
                Evidence = GetEvidenceOrNull(f),
            });
        }
        return findings;
    }

    private static List<string>? GetStringListOrNull(JsonElement obj, string name)
    {
        if (obj.ValueKind != JsonValueKind.Object || !obj.TryGetProperty(name, out var arr) || arr.ValueKind != JsonValueKind.Array)
            return null;
        var list = new List<string>();
        foreach (var e in arr.EnumerateArray())
            if (e.GetString() is { } str) list.Add(str);
        return list.Count > 0 ? list : null;
    }

    // Flattens a finding's evidence array (objects with file/line) into "file:line"
    // strings for compact display.
    private static List<string>? GetEvidenceOrNull(JsonElement finding)
    {
        if (!finding.TryGetProperty("evidence", out var arr) || arr.ValueKind != JsonValueKind.Array)
            return null;
        var list = new List<string>();
        foreach (var e in arr.EnumerateArray())
        {
            var file = GetStringOrNull(e, "file");
            if (file is null) continue;
            var line = e.TryGetProperty("line", out var l) && l.ValueKind == JsonValueKind.Number ? l.GetInt32() : 0;
            list.Add(line > 0 ? $"{file}:{line}" : file);
        }
        return list.Count > 0 ? list : null;
    }

    private static string? GetStringOrNull(JsonElement obj, string name)
        => obj.ValueKind == JsonValueKind.Object && obj.TryGetProperty(name, out var v) ? v.GetString() : null;

    // Resolves the "epic-compliance-review" build artifact, downloads the zip
    // container, and returns the first entry with the given extension's text.
    // Shared by the Markdown (download) and JSON (summary) accessors.
    private async Task<string?> ReadComplianceArtifactEntryAsync(int buildId, string extension, CancellationToken ct)
    {
        var metaUrl = $"{BaseUrl}/build/builds/{buildId}/artifacts?artifactName={ComplianceArtifactName}&api-version=7.1";

        var meta = await SendAsync(metaUrl, ct);
        if (meta is null)
        {
            logger.LogWarning("Compliance artifact metadata not found for build {BuildId}", buildId);
            return null;
        }

        using var metaDoc = JsonDocument.Parse(meta);
        if (!metaDoc.RootElement.TryGetProperty("resource", out var resource) ||
            !resource.TryGetProperty("downloadUrl", out var dl) ||
            dl.GetString() is not { Length: > 0 } downloadUrl)
        {
            logger.LogWarning("Compliance artifact for build {BuildId} has no downloadUrl", buildId);
            return null;
        }

        using var request = new HttpRequestMessage(HttpMethod.Get, downloadUrl);
        var credentials = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{Pat}"));
        request.Headers.Authorization = new AuthenticationHeaderValue(BasicScheme, credentials);

        var response = await httpClient.SendAsync(request, ct);
        if (!response.IsSuccessStatusCode)
        {
            logger.LogWarning("ADO artifact download returned {StatusCode} for build {BuildId}", (int)response.StatusCode, buildId);
            return null;
        }

        await using var zipStream = await response.Content.ReadAsStreamAsync(ct);
        // CreateAsync reads the zip central directory without blocking the thread
        // on the network stream (the synchronous ZipArchive ctor does — S6966).
        using var archive = await System.IO.Compression.ZipArchive.CreateAsync(
            zipStream, System.IO.Compression.ZipArchiveMode.Read, leaveOpen: false, entryNameEncoding: null, ct);

        var entry = archive.Entries.FirstOrDefault(e => e.FullName.EndsWith(extension, StringComparison.OrdinalIgnoreCase));
        if (entry is null)
        {
            logger.LogWarning("Compliance artifact for build {BuildId} contains no {Extension} report", buildId, extension);
            return null;
        }

        await using var entryStream = await entry.OpenAsync(ct);
        using var reader = new StreamReader(entryStream);
        return await reader.ReadToEndAsync(ct);
    }

    // Small helper: GET a URL with the ADO PAT, returning the body or null on
    // a non-success status.
    private async Task<string?> SendAsync(string url, CancellationToken ct)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        var credentials = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{Pat}"));
        request.Headers.Authorization = new AuthenticationHeaderValue(BasicScheme, credentials);

        var response = await httpClient.SendAsync(request, ct);
        if (!response.IsSuccessStatusCode)
        {
            return null;
        }
        return await response.Content.ReadAsStringAsync(ct);
    }

    private const string ComplianceArtifactName = "epic-compliance-review";

    private static bool MatchesStageName(string? recordName, string stageName) => stageName switch
    {
        "review" => recordName is "Review" or "Review App",
        "build" => recordName is "Build" or "Build App",
        "test" => recordName is "BuildTest" or "UnitTest" or "Build Tests" or "Unit Tests",
        "scan" => recordName is "Scan" or "Scan App",
        "infraDeploy" => recordName is "DeployInfra" or "Deploy Infrastructure",
        "appDeploy" => recordName is "Deploy" or "Deploy App",
        "integrationTest" => recordName is "IntegrationTest" or "Integration Tests",
        _ => false
    };

    private static string? ComputeDuration(JsonElement record)
    {
        var start = record.TryGetProperty(PropStartTime, out var st) && st.ValueKind != JsonValueKind.Null
            ? st.GetDateTime() : (DateTime?)null;
        var finish = record.TryGetProperty(PropFinishTime, out var ft) && ft.ValueKind != JsonValueKind.Null
            ? ft.GetDateTime() : (DateTime?)null;
        if (start.HasValue && finish.HasValue)
            return FormatDuration(finish.Value - start.Value);
        return null;
    }

    private static string MapRunStatus(string? state, string? result) => state switch
    {
        "completed" => result switch
        {
            "succeeded" => "Success",
            "failed" => StatusFailed,
            "canceled" => "Canceled",
            _ => StatusFailed
        },
        "inProgress" => StatusRunning,
        "canceling" => "Canceled",
        "notStarted" => StatusRunning,
        _ => StatusRunning
    };

    private static RunStatus MapStageStatus(string? state, string? result)
    {
        if (state == "completed")
        {
            return result switch
            {
                "succeeded" => RunStatus.Success,
                "failed" => RunStatus.Failed,
                "canceled" or "cancelled" => RunStatus.Canceled,
                "skipped" => RunStatus.Skipped,
                _ => RunStatus.Failed
            };
        }

        return state switch
        {
            "inProgress" => RunStatus.Running,
            "pending" => RunStatus.Pending,
            _ => RunStatus.Pending
        };
    }

    private static string FormatDuration(TimeSpan ts)
    {
        if (ts.TotalHours >= 1) return $"{(int)ts.TotalHours}h {ts.Minutes}m";
        return $"{ts.Minutes}m {ts.Seconds:D2}s";
    }

    public async Task<AdoTriggerResult> TriggerOrchestratorAsync(
        string repo, string branch, string environment, string config,
        bool review, bool build, bool tests, bool scan, bool deploy, bool integrations,
        string deployInfra, bool forceStateCopy, string triggeredBy,
        string owner, string githubHost, CancellationToken ct = default)
    {
        var url = $"https://dev.azure.com/{Org}/{Project}/_apis/pipelines/{OrchestratorPipelineId}/runs?api-version=7.1";

        var payload = new
        {
            templateParameters = new Dictionary<string, string>
            {
                ["repo"] = repo,
                // GitHub org + host the agent clones from; lets EPIC pull from more
                // than one org/Enterprise host. Orchestrator defaults these when absent.
                ["owner"] = owner,
                ["githubHost"] = githubHost,
                [PropBranch] = branch,
                ["config"] = config,
                [PropEnvironment] = environment,
                ["triggeredBy"] = triggeredBy,
                ["review"] = review.ToString(),
                ["build"] = build.ToString(),
                ["tests"] = tests.ToString(),
                ["scan"] = scan.ToString(),
                ["deploy"] = deploy.ToString(),
                ["integrations"] = integrations.ToString(),
                ["deployInfra"] = deployInfra,
                ["forceStateCopy"] = forceStateCopy.ToString()
            }
        };

        var json = JsonSerializer.Serialize(payload);

        using var request = new HttpRequestMessage(HttpMethod.Post, url);
        var credentials = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{Pat}"));
        request.Headers.Authorization = new AuthenticationHeaderValue(BasicScheme, credentials);
        request.Content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");

        var response = await httpClient.SendAsync(request, ct);
        var body = await response.Content.ReadAsStringAsync(ct);

        if (!response.IsSuccessStatusCode)
            throw new InvalidOperationException($"ADO API returned {(int)response.StatusCode}: {body}");

        var result = JsonDocument.Parse(body).RootElement;
        var runId = result.GetProperty("id").GetInt32();

        return new AdoTriggerResult
        {
            RunId = runId,
            Url = $"https://dev.azure.com/{Org}/{Project}/_build/results?buildId={runId}&view=results"
        };
    }

    public async Task CancelBuildAsync(int buildId, CancellationToken ct = default)
    {
        var url = $"{BaseUrl}/build/builds/{buildId}?api-version=7.1";
        var json = JsonSerializer.Serialize(new { status = "cancelling" });

        using var request = new HttpRequestMessage(HttpMethod.Patch, url);
        var credentials = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{Pat}"));
        request.Headers.Authorization = new AuthenticationHeaderValue(BasicScheme, credentials);
        request.Content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");

        var response = await httpClient.SendAsync(request, ct);

        if (!response.IsSuccessStatusCode)
        {
            var body = await response.Content.ReadAsStringAsync(ct);

            // Cancelling a build that has already completed (or doesn't exist) is a no-op,
            // not an error — ADO returns 400/404 in that case. This keeps cancel idempotent
            // so we can safely cancel both the orchestrator and engine builds even when one
            // of them has already finished (e.g. the fire-and-forget orchestrator).
            if (response.StatusCode is System.Net.HttpStatusCode.BadRequest or System.Net.HttpStatusCode.NotFound)
            {
                logger.LogInformation("Cancel no-op for build {BuildId}: ADO returned {Status} (already completed or not found)", buildId, (int)response.StatusCode);
                return;
            }

            throw new InvalidOperationException($"ADO API returned {(int)response.StatusCode}: {body}");
        }
    }

    private async Task<JsonElement?> CallApiAsync(string url, CancellationToken ct)
    {
        var (json, _) = await CallApiWithContinuationAsync(url, ct);
        return json;
    }

    /// <summary>
    /// Same as CallApiAsync but also returns the x-ms-continuationtoken response header
    /// for paginated ADO endpoints (e.g. /build/builds).
    /// </summary>
    private async Task<(JsonElement? Json, string? ContinuationToken)> CallApiWithContinuationAsync(string url, CancellationToken ct)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        var credentials = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{Pat}"));
        request.Headers.Authorization = new AuthenticationHeaderValue(BasicScheme, credentials);

        var response = await httpClient.SendAsync(request, ct);

        if (!response.IsSuccessStatusCode)
        {
            logger.LogWarning("ADO API returned {StatusCode} for {Url}", (int)response.StatusCode, url);
            return (null, null);
        }

        var body = await response.Content.ReadAsStringAsync(ct);
        var json = JsonDocument.Parse(body).RootElement;

        string? continuationToken = null;
        if (response.Headers.TryGetValues("x-ms-continuationtoken", out var values))
            continuationToken = values.FirstOrDefault();

        return (json, continuationToken);
    }
}
