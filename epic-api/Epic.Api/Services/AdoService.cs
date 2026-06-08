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

    private string Pat =>
        configuration["ADO_PAT"]
        ?? throw new InvalidOperationException("ADO_PAT not configured.");

    private string BaseUrl => $"https://dev.azure.com/{Org}/{Project}/_apis";

    public async Task<List<AdoPipelineRun>> GetRunsForAppAsync(string appName, int? afterBuildId = null, int top = 20, CancellationToken ct = default)
    {
        // One API call — filter by appName tag
        var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{appName}")}&$top={top}&queryOrder=queueTimeDescending&api-version=7.1";
        var buildsJson = await CallApiAsync(url, ct);

        if (buildsJson is null) return [];

        var results = new List<AdoPipelineRun>();

        foreach (var build in buildsJson.Value.GetProperty("value").EnumerateArray())
        {
            var buildId = build.GetProperty("id").GetInt32();

            // Skip builds we already have (everything at or before afterBuildId)
            if (afterBuildId.HasValue && buildId <= afterBuildId.Value)
                continue;

            var adoStatus = build.TryGetProperty("status", out var st) ? st.GetString() : "unknown";
            var adoResult = build.TryGetProperty("result", out var res) ? res.GetString() : null;
            var status = MapRunStatus(adoStatus, adoResult);

            var triggeredBy = build.TryGetProperty("requestedFor", out var rf)
                && rf.TryGetProperty("displayName", out var dn)
                ? dn.GetString() ?? "Unknown" : "Unknown";

            var branch = "";
            var environment = "dev";

            if (build.TryGetProperty("templateParameters", out var tp) && tp.ValueKind == JsonValueKind.Object)
            {
                branch = tp.TryGetProperty("branch", out var br) ? br.GetString() ?? "" : "";
                environment = tp.TryGetProperty("environment", out var env) ? env.GetString() ?? "dev" : "dev";
            }

            if (string.IsNullOrEmpty(branch))
            {
                var paramsString = build.TryGetProperty("parameters", out var p) && p.ValueKind == JsonValueKind.String
                    ? p.GetString() : null;
                if (paramsString is not null)
                {
                    try
                    {
                        var paramObj = JsonDocument.Parse(paramsString).RootElement;
                        branch = paramObj.TryGetProperty("branch", out var br2) ? br2.GetString() ?? "" : "";
                        environment = paramObj.TryGetProperty("environment", out var env2) ? env2.GetString() ?? "dev" : "dev";
                    }
                    catch (Exception ex) { logger.LogDebug(ex, "ADO build parameters not parseable — using defaults"); }
                }
            }

            if (string.IsNullOrEmpty(branch))
            {
                branch = build.TryGetProperty("sourceBranch", out var sb)
                    ? sb.GetString()?.Replace("refs/heads/", "") ?? "" : "";
            }

            var startedAt = build.TryGetProperty("startTime", out var st2)
                && st2.ValueKind != JsonValueKind.Null
                ? st2.GetDateTime()
                : build.TryGetProperty("queueTime", out var qt)
                    ? qt.GetDateTime() : DateTime.UtcNow;

            var finishedAt = build.TryGetProperty("finishTime", out var ft)
                && ft.ValueKind != JsonValueKind.Null
                ? ft.GetDateTime() : (DateTime?)null;

            var duration = finishedAt.HasValue
                ? FormatDuration(finishedAt.Value - startedAt)
                : null;

            // Get stage-level results from the timeline
            var stages = await GetStageResultsAsync(buildId, isTerminal: status != "Running", ct);

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
        await ResolveTriggeredByFromOrchestratorAsync(appName, results, ct);

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
    public async Task<List<AdoLatestRun>> GetRecentRunsForAppAsync(string appName, int top = 20, CancellationToken ct = default)
    {
        var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{appName}")}&$top={top}&queryOrder=queueTimeDescending&api-version=7.1";
        var buildsJson = await CallApiAsync(url, ct);

        if (buildsJson is null) return [];

        var results = new List<AdoLatestRun>();

        foreach (var build in buildsJson.Value.GetProperty("value").EnumerateArray())
        {
            var adoStatus = build.TryGetProperty("status", out var st) ? st.GetString() : "unknown";
            var adoResult = build.TryGetProperty("result", out var res) ? res.GetString() : null;

            var triggeredBy = build.TryGetProperty("requestedFor", out var rf)
                && rf.TryGetProperty("displayName", out var dn)
                ? dn.GetString() ?? "Unknown" : "Unknown";

            var branch = "";
            var environment = "dev";

            if (build.TryGetProperty("templateParameters", out var tp) && tp.ValueKind == JsonValueKind.Object)
            {
                branch = tp.TryGetProperty("branch", out var br) ? br.GetString() ?? "" : "";
                environment = tp.TryGetProperty("environment", out var env) ? env.GetString() ?? "dev" : "dev";
            }

            if (string.IsNullOrEmpty(branch))
            {
                var paramsString = build.TryGetProperty("parameters", out var p) && p.ValueKind == JsonValueKind.String
                    ? p.GetString() : null;
                if (paramsString is not null)
                {
                    try
                    {
                        var paramObj = JsonDocument.Parse(paramsString).RootElement;
                        branch = paramObj.TryGetProperty("branch", out var br2) ? br2.GetString() ?? "" : "";
                        environment = paramObj.TryGetProperty("environment", out var env2) ? env2.GetString() ?? "dev" : "dev";
                    }
                    catch (Exception ex) { logger.LogDebug(ex, "ADO build parameters not parseable — using defaults"); }
                }
            }

            if (string.IsNullOrEmpty(branch))
            {
                branch = build.TryGetProperty("sourceBranch", out var sb)
                    ? sb.GetString()?.Replace("refs/heads/", "") ?? "" : "";
            }

            var startedAt = build.TryGetProperty("startTime", out var st2)
                && st2.ValueKind != JsonValueKind.Null
                ? st2.GetDateTime()
                : build.TryGetProperty("queueTime", out var qt)
                    ? qt.GetDateTime() : DateTime.UtcNow;

            var finishedAt = build.TryGetProperty("finishTime", out var ft)
                && ft.ValueKind != JsonValueKind.Null
                ? ft.GetDateTime() : (DateTime?)null;

            string? cloud = null;
            string? tagEnvironment = null;
            string? appType = null;
            string? tagAppName = null;
            if (build.TryGetProperty("tags", out var tags) && tags.ValueKind == JsonValueKind.Array)
            {
                foreach (var tag in tags.EnumerateArray())
                {
                    var tagStr = tag.GetString();
                    if (tagStr is null) continue;
                    if (tagStr.StartsWith("epicCloud."))
                        cloud = tagStr["epicCloud.".Length..];
                    else if (tagStr.StartsWith("epicEnvironment."))
                        tagEnvironment = tagStr["epicEnvironment.".Length..];
                    else if (tagStr.StartsWith("epicAppType."))
                        appType = tagStr["epicAppType.".Length..];
                    else if (tagStr.StartsWith("epicAppName."))
                        tagAppName = tagStr["epicAppName.".Length..];
                }
            }

            results.Add(new AdoLatestRun
            {
                Id = build.GetProperty("id").GetInt32(),
                Status = MapRunStatus(adoStatus, adoResult),
                TriggeredBy = triggeredBy,
                Branch = branch,
                Environment = tagEnvironment ?? environment,
                Cloud = cloud,
                AppType = appType,
                AppName = tagAppName,
                StartedAt = startedAt,
                Duration = finishedAt.HasValue ? FormatDuration(finishedAt.Value - startedAt) : null
            });
        }

        // Resolve real triggeredBy from orchestrator pipeline (single bulk call)
        var orchRuns = await ResolveTriggeredByFromOrchestratorAsync(appName, results, ct);

        // Include unmatched orchestrators so the main table shows "Running" during prepare
        // Ignore succeeded orchestrators with no engine after 5 minutes (stale/orphaned)
        var now = DateTime.UtcNow;
        foreach (var orch in orchRuns.Where(o => !o.Matched && !(o.Status == RunStatus.Success && o.FinishTime.HasValue && (now - o.FinishTime.Value).TotalMinutes > 2)))
        {
            results.Add(new AdoLatestRun
            {
                Id = orch.Id,
                Status = orch.Status == RunStatus.Failed ? "Failed" : "Running",
                TriggeredBy = orch.RequestedFor ?? "Unknown",
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

            foreach (var build in json.Value.GetProperty("value").EnumerateArray())
            {
                var result = build.TryGetProperty("result", out var r) ? r.GetString() : null;
                if (result == "canceled") continue;
                total++;
                if (result == "succeeded") successful++;

                var startedAt = build.TryGetProperty("startTime", out var st) && st.ValueKind != JsonValueKind.Null
                    ? st.GetDateTime() : (DateTime?)null;
                var finishedAt = build.TryGetProperty("finishTime", out var ft) && ft.ValueKind != JsonValueKind.Null
                    ? ft.GetDateTime() : (DateTime?)null;
                if (startedAt.HasValue && finishedAt.HasValue)
                    totalDuration += finishedAt.Value - startedAt.Value;
            }

            continuationToken = nextToken;
        } while (!string.IsNullOrEmpty(continuationToken));

        return (total, successful, totalDuration);
    }

    /// <summary>
    /// Counts ALL runs for an app (any status, including in-progress) by paginating
    /// through every build with the appName tag. Used to compute the pagination total
    /// for the manage modal's runs table.
    /// </summary>
    public async Task<int> GetTotalRunCountAsync(string appName, CancellationToken ct = default)
    {
        var cacheKey = $"runcount:{appName}";
        if (cache.TryGetValue(cacheKey, out int cached))
            return cached;

        var total = 0;
        string? continuationToken = null;
        const int pageSize = 1000;

        do
        {
            var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{appName}")}&$top={pageSize}&queryOrder=queueTimeDescending&api-version=7.1";
            if (continuationToken is not null)
                url += $"&continuationToken={Uri.EscapeDataString(continuationToken)}";

            var (json, nextToken) = await CallApiWithContinuationAsync(url, ct);
            if (json is null) break;

            total += json.Value.GetProperty("value").GetArrayLength();
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
    public async Task<AdoRunsPage> GetRunsPageAsync(string appName, int page, int pageSize, CancellationToken ct = default)
    {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 20;

        // Kick off the total count in parallel — it's an independent set of calls.
        var totalTask = GetTotalRunCountAsync(appName, ct);

        // Walk continuation tokens until we reach the target page.
        JsonElement? pageJson = null;
        string? continuationToken = null;
        for (var i = 1; i <= page; i++)
        {
            var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{appName}")}&$top={pageSize}&queryOrder=queueTimeDescending&api-version=7.1";
            if (continuationToken is not null)
                url += $"&continuationToken={Uri.EscapeDataString(continuationToken)}";

            var (json, nextToken) = await CallApiWithContinuationAsync(url, ct);
            if (json is null) break;

            if (i == page)
            {
                pageJson = json;
                break;
            }

            // No more pages available — we asked for a page beyond the end.
            if (string.IsNullOrEmpty(nextToken)) break;
            continuationToken = nextToken;
        }

        var results = new List<AdoPipelineRun>();
        if (pageJson is not null)
        {
            foreach (var build in pageJson.Value.GetProperty("value").EnumerateArray())
            {
                var run = await MapBuildToRunAsync(build, includeStages: true, ct);
                results.Add(run);
            }

            var orchRuns = await ResolveTriggeredByFromOrchestratorAsync(appName, results, ct);

            // Include unmatched failed/running orchestrators as standalone "Prepare" entries
            if (page == 1)
            {
                var now = DateTime.UtcNow;
                var unmatchedOrch = orchRuns
                    .Where(o => !o.Matched)
                    .Where(o => !(o.Status == RunStatus.Success && o.FinishTime.HasValue && (now - o.FinishTime.Value).TotalMinutes > 2))
                    .ToList();

                foreach (var orch in unmatchedOrch)
                {
                    var prepareStatus = orch.Status;
                    // Overall run status: Failed if orchestrator failed, otherwise Running
                    // (either orchestrator is still running, or it succeeded but engine hasn't started yet)
                    var overallStatus = orch.Status == RunStatus.Failed ? "Failed" : "Running";

                    results.Add(new AdoPipelineRun
                    {
                        Id = orch.Id,
                        OrchestratorId = orch.Id,
                        Status = overallStatus,
                        TriggeredBy = orch.RequestedFor ?? "Unknown",
                        Branch = orch.Branch,
                        Environment = orch.Environment,
                        StartedAt = orch.StartedAt,
                        Duration = null,
                        Stages = new PipelineStages
                        {
                            Prepare = prepareStatus,
                            Download = orch.Status == RunStatus.Success ? RunStatus.Running : RunStatus.Skipped,
                            Build = RunStatus.Skipped,
                            Test = RunStatus.Skipped,
                            Scan = RunStatus.Skipped,
                            InfraDeploy = RunStatus.Skipped,
                            AppDeploy = RunStatus.Skipped,
                            IntegrationTest = RunStatus.Skipped
                        }
                    });
                }

                results = results.OrderByDescending(r => r.StartedAt).ToList();
            }
        }

        var total = await totalTask;

        return new AdoRunsPage { Total = total, Runs = results };
    }

    private async Task<AdoPipelineRun> MapBuildToRunAsync(JsonElement build, bool includeStages, CancellationToken ct)
    {
        var buildId = build.GetProperty("id").GetInt32();

        var adoStatus = build.TryGetProperty("status", out var st) ? st.GetString() : "unknown";
        var adoResult = build.TryGetProperty("result", out var res) ? res.GetString() : null;
        var status = MapRunStatus(adoStatus, adoResult);

        var triggeredBy = build.TryGetProperty("requestedFor", out var rf)
            && rf.TryGetProperty("displayName", out var dn)
            ? dn.GetString() ?? "Unknown" : "Unknown";

        var branch = "";
        var environment = "dev";

        // templateParameters is where the orchestrator passes values to the engine
        if (build.TryGetProperty("templateParameters", out var tp) && tp.ValueKind == JsonValueKind.Object)
        {
            branch = tp.TryGetProperty("branch", out var br) ? br.GetString() ?? "" : "";
            environment = tp.TryGetProperty("environment", out var env) ? env.GetString() ?? "dev" : "dev";
        }

        // Fall back to runtime parameters
        if (string.IsNullOrEmpty(branch))
        {
            var paramsString = build.TryGetProperty("parameters", out var p) && p.ValueKind == JsonValueKind.String
                ? p.GetString() : null;
            if (paramsString is not null)
            {
                try
                {
                    var paramObj = JsonDocument.Parse(paramsString).RootElement;
                    branch = paramObj.TryGetProperty("branch", out var br2) ? br2.GetString() ?? "" : "";
                    environment = paramObj.TryGetProperty("environment", out var env2) ? env2.GetString() ?? "dev" : "dev";
                }
                catch (Exception ex) { logger.LogDebug(ex, "ADO build parameters not parseable — using defaults"); }
            }
        }

        // Last resort: pipeline source branch
        if (string.IsNullOrEmpty(branch))
        {
            branch = build.TryGetProperty("sourceBranch", out var sb)
                ? sb.GetString()?.Replace("refs/heads/", "") ?? "" : "";
        }

        var startedAt = build.TryGetProperty("startTime", out var st2)
            && st2.ValueKind != JsonValueKind.Null
            ? st2.GetDateTime()
            : build.TryGetProperty("queueTime", out var qt)
                ? qt.GetDateTime() : DateTime.UtcNow;

        var finishedAt = build.TryGetProperty("finishTime", out var ft)
            && ft.ValueKind != JsonValueKind.Null
            ? ft.GetDateTime() : (DateTime?)null;

        var duration = finishedAt.HasValue ? FormatDuration(finishedAt.Value - startedAt) : null;

        var stages = includeStages
            ? await GetStageResultsAsync(buildId, isTerminal: status != "Running", ct)
            : new PipelineStages
            {
                Prepare = RunStatus.Success,
                Download = RunStatus.Success,
                Build = RunStatus.Skipped,
                Test = RunStatus.Skipped,
                Scan = RunStatus.Skipped,
                InfraDeploy = RunStatus.Skipped,
                AppDeploy = RunStatus.Skipped,
                IntegrationTest = RunStatus.Skipped
            };

        string? epicAppName = null;
        string? epicCloud = null;
        string? epicEnvironment = null;
        if (build.TryGetProperty("tags", out var tags) && tags.ValueKind == JsonValueKind.Array)
        {
            foreach (var tag in tags.EnumerateArray())
            {
                var tagStr = tag.GetString();
                if (tagStr is null) continue;
                if (tagStr.StartsWith("epicAppName."))
                    epicAppName = tagStr["epicAppName.".Length..];
                else if (tagStr.StartsWith("epicCloud."))
                    epicCloud = tagStr["epicCloud.".Length..];
                else if (tagStr.StartsWith("epicEnvironment."))
                    epicEnvironment = tagStr["epicEnvironment.".Length..];
            }
        }

        return new AdoPipelineRun
        {
            Id = buildId,
            Status = status,
            TriggeredBy = triggeredBy,
            Branch = branch,
            Environment = epicEnvironment ?? environment,
            Cloud = epicCloud,
            AppName = epicAppName,
            StartedAt = startedAt,
            Duration = duration,
            Stages = stages
        };
    }

    /// <summary>
    /// Queries orchestrator builds (tagged with appName) and matches each engine run
    /// to its orchestrator run by time proximity, overriding TriggeredBy with the real user
    /// and setting the Prepare stage status from the orchestrator's result.
    /// </summary>
    private Task<List<OrchestratorInfo>> ResolveTriggeredByFromOrchestratorAsync(string appName, List<AdoPipelineRun> engineRuns, CancellationToken ct) =>
        ResolveTriggeredByFromOrchestratorCoreAsync(
            appName,
            engineRuns.Count,
            engineRuns.Select<AdoPipelineRun, (DateTime StartedAt, Action<string> SetTriggeredBy, Action<RunStatus>? SetPrepare, Action<int>? SetOrchestratorId)>(
                r => (r.StartedAt, s => r.TriggeredBy = s, s => r.Stages.Prepare = s, id => r.OrchestratorId = id)).ToList(),
            ct);

    private Task<List<OrchestratorInfo>> ResolveTriggeredByFromOrchestratorAsync(string appName, List<AdoLatestRun> engineRuns, CancellationToken ct) =>
        ResolveTriggeredByFromOrchestratorCoreAsync(
            appName,
            engineRuns.Count,
            engineRuns.Select<AdoLatestRun, (DateTime StartedAt, Action<string> SetTriggeredBy, Action<RunStatus>? SetPrepare, Action<int>? SetOrchestratorId)>(
                r => (r.StartedAt, s => r.TriggeredBy = s, null, null)).ToList(),
            ct);

    private async Task<List<OrchestratorInfo>> ResolveTriggeredByFromOrchestratorCoreAsync(
        string appName,
        int totalRuns,
        List<(DateTime StartedAt, Action<string> SetTriggeredBy, Action<RunStatus>? SetPrepare, Action<int>? SetOrchestratorId)> engineRuns,
        CancellationToken ct)
    {
        var url = $"{BaseUrl}/build/builds?definitions={OrchestratorPipelineId}&tagFilters={Uri.EscapeDataString($"epicRepo.{appName}")}&$top={Math.Max(totalRuns + 5, 20)}&queryOrder=queueTimeDescending&api-version=7.1";
        var json = await CallApiAsync(url, ct);
        if (json is null) return [];

        var orchRuns = json.Value.GetProperty("value").EnumerateArray()
            .Select(b =>
            {
                var id = b.GetProperty("id").GetInt32();
                var ft = b.TryGetProperty("finishTime", out var f) && f.ValueKind != JsonValueKind.Null
                    ? f.GetDateTime() : (DateTime?)null;
                var st = b.TryGetProperty("startTime", out var s) && s.ValueKind != JsonValueKind.Null
                    ? s.GetDateTime() : b.TryGetProperty("queueTime", out var qt) ? qt.GetDateTime() : DateTime.UtcNow;
                var reqFor = b.TryGetProperty("requestedFor", out var rf)
                    && rf.TryGetProperty("displayName", out var dn)
                    ? dn.GetString() : null;
                var adoStatus = b.TryGetProperty("status", out var statusProp) ? statusProp.GetString() : "unknown";
                var adoResult = b.TryGetProperty("result", out var resProp) ? resProp.GetString() : null;

                var branch = "";
                var environment = "dev";
                if (b.TryGetProperty("templateParameters", out var tp) && tp.ValueKind == JsonValueKind.Object)
                {
                    branch = tp.TryGetProperty("branch", out var br) ? br.GetString() ?? "" : "";
                    environment = tp.TryGetProperty("environment", out var env) ? env.GetString() ?? "dev" : "dev";
                }
                if (string.IsNullOrEmpty(branch))
                {
                    var paramsString = b.TryGetProperty("parameters", out var p) && p.ValueKind == JsonValueKind.String ? p.GetString() : null;
                    if (paramsString is not null)
                    {
                        try
                        {
                            var paramObj = JsonDocument.Parse(paramsString).RootElement;
                            branch = paramObj.TryGetProperty("branch", out var br2) ? br2.GetString() ?? "" : "";
                            environment = paramObj.TryGetProperty("environment", out var env2) ? env2.GetString() ?? "dev" : "dev";
                        }
                        catch (Exception ex) { logger.LogDebug(ex, "ADO build parameters not parseable — using defaults"); }
                    }
                }

                return new OrchestratorInfo
                {
                    Id = id,
                    FinishTime = ft,
                    StartedAt = st,
                    RequestedFor = reqFor,
                    Status = MapStageStatus(adoStatus, adoResult),
                    Branch = branch,
                    Environment = environment,
                    Matched = false
                };
            })
            .ToList();

        if (orchRuns.Count == 0 || engineRuns.Count == 0) return orchRuns;

        foreach (var run in engineRuns)
        {
            // Match finished orchestrators: orch must have finished before engine start + 5 min
            var match = orchRuns
                .Where(o => !o.Matched && o.FinishTime.HasValue && o.FinishTime.Value <= run.StartedAt.AddMinutes(5))
                .MinBy(o => run.StartedAt - o.FinishTime!.Value);

            // Fall back to still-running orchestrators: orch started before engine, within 5 min
            match ??= orchRuns
                .Where(o => !o.Matched && !o.FinishTime.HasValue && o.StartedAt <= run.StartedAt && (run.StartedAt - o.StartedAt).TotalMinutes <= 5)
                .MinBy(o => run.StartedAt - o.StartedAt);

            if (match is not null)
            {
                match.Matched = true;
                if (match.RequestedFor is not null)
                    run.SetTriggeredBy(match.RequestedFor);
                run.SetPrepare?.Invoke(match.Status);
                run.SetOrchestratorId?.Invoke(match.Id);
            }
        }

        return orchRuns;
    }

    private sealed class OrchestratorInfo
    {
        public int Id { get; set; }
        public DateTime? FinishTime { get; set; }
        public DateTime StartedAt { get; set; }
        public string? RequestedFor { get; set; }
        public RunStatus Status { get; set; }
        public string Branch { get; set; } = "";
        public string Environment { get; set; } = "dev";
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

        var stages = new PipelineStages
        {
            Prepare = RunStatus.Success,
            Download = RunStatus.Success,
            Build = RunStatus.Skipped,
            Test = RunStatus.Skipped,
            Scan = RunStatus.Skipped,
            InfraDeploy = RunStatus.Skipped,
            AppDeploy = RunStatus.Skipped,
            IntegrationTest = RunStatus.Skipped
        };

        if (timelineJson is null) return stages;

        foreach (var record in timelineJson.Value.GetProperty("records").EnumerateArray())
        {
            var type = record.TryGetProperty("type", out var t) ? t.GetString() : null;
            if (type != "Stage") continue;

            var name = record.TryGetProperty("name", out var n) ? n.GetString() : null;
            var state = record.TryGetProperty("state", out var s) ? s.GetString() : null;
            var result = record.TryGetProperty("result", out var r) ? r.GetString() : null;
            var stageStatus = MapStageStatus(state, result);

            switch (name)
            {
                case "Download" or "Download Source":
                    stages.Download = stageStatus;
                    break;
                case "Build" or "Build App":
                    stages.Build = stageStatus;
                    break;
                case "UnitTest" or "Unit Tests":
                    stages.Test = stageStatus;
                    break;
                case "Scan" or "Scan App":
                    stages.Scan = stageStatus;
                    break;
                case "DeployInfra" or "Deploy Infrastructure":
                    stages.InfraDeploy = stageStatus;
                    break;
                case "Deploy" or "Deploy App":
                    stages.AppDeploy = stageStatus;
                    break;
                case "IntegrationTest" or "Integration Tests":
                    stages.IntegrationTest = stageStatus;
                    break;
            }
        }

        // When the run is terminal, ADO may leave some stages as inProgress/pending
        // (e.g. when a stage fails and the run is canceled mid-flight). Correct these
        // so the UI doesn't show blue/hollow dots on a completed run.
        if (isTerminal)
        {
            stages.Download = ReconcileTerminalStage(stages.Download);
            stages.Build = ReconcileTerminalStage(stages.Build);
            stages.Test = ReconcileTerminalStage(stages.Test);
            stages.Scan = ReconcileTerminalStage(stages.Scan);
            stages.InfraDeploy = ReconcileTerminalStage(stages.InfraDeploy);
            stages.AppDeploy = ReconcileTerminalStage(stages.AppDeploy);
            stages.IntegrationTest = ReconcileTerminalStage(stages.IntegrationTest);

            cache.Set(cacheKey, stages, new MemoryCacheEntryOptions
            {
                SlidingExpiration = TimelineCacheTtl,
                Size = 1
            });
        }

        return stages;
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

        // Index every record by id, and build parent→children lookup
        var byId = new Dictionary<string, JsonElement>();
        var childrenOf = new Dictionary<string, List<string>>();
        foreach (var record in records.EnumerateArray())
        {
            var id = record.TryGetProperty("id", out var idProp) ? idProp.GetString() : null;
            if (id is null) continue;
            byId[id] = record;
            var parentId = record.TryGetProperty("parentId", out var p) ? p.GetString() : null;
            if (parentId is not null)
            {
                if (!childrenOf.ContainsKey(parentId)) childrenOf[parentId] = [];
                childrenOf[parentId].Add(id);
            }
        }

        // Find the matching Stage record
        string? stageId = null;
        JsonElement? stageRecord = null;
        foreach (var record in records.EnumerateArray())
        {
            var type = record.TryGetProperty("type", out var t) ? t.GetString() : null;
            if (type != "Stage") continue;
            var name = record.TryGetProperty("name", out var n) ? n.GetString() : null;
            if (!MatchesStageName(name, stageName)) continue;
            stageId = record.GetProperty("id").GetString();
            stageRecord = record;
            break;
        }

        if (stageId is null || stageRecord is null) return null;

        // Collect all descendant IDs of the stage (Phase, Job, etc.)
        var descendants = new HashSet<string>();
        var queue = new Queue<string>();
        queue.Enqueue(stageId);
        while (queue.Count > 0)
        {
            var current = queue.Dequeue();
            if (!childrenOf.TryGetValue(current, out var children)) continue;
            foreach (var childId in children)
            {
                descendants.Add(childId);
                queue.Enqueue(childId);
            }
        }

        // Collect all Task records that are descendants of the stage
        var stepEntries = new List<(int Order, StageStep Step)>();
        foreach (var descId in descendants)
        {
            if (!byId.TryGetValue(descId, out var record)) continue;
            var type = record.TryGetProperty("type", out var t) ? t.GetString() : null;
            if (type != "Task") continue;

            int? logId = record.TryGetProperty("log", out var logProp)
                && logProp.ValueKind == JsonValueKind.Object
                && logProp.TryGetProperty("id", out var logIdProp)
                ? logIdProp.GetInt32() : null;

            var order = record.TryGetProperty("order", out var o) ? o.GetInt32() : 0;

            stepEntries.Add((order, new StageStep
            {
                Name = record.TryGetProperty("name", out var n) ? n.GetString() ?? "Step" : "Step",
                Status = MapStageStatus(
                    record.TryGetProperty("state", out var s) ? s.GetString() : null,
                    record.TryGetProperty("result", out var r) ? r.GetString() : null),
                Duration = ComputeDuration(record),
                LogId = logId
            }));
        }

        stepEntries.Sort((a, b) => a.Order.CompareTo(b.Order));
        var steps = stepEntries.Select(e => e.Step).ToList();

        var stageState = stageRecord.Value.TryGetProperty("state", out var ss) ? ss.GetString() : null;
        var stageResult = stageRecord.Value.TryGetProperty("result", out var sr) ? sr.GetString() : null;

        // Wrap steps in a single synthetic job (the frontend flattens jobs→steps anyway)
        return new StageDetail
        {
            StageName = stageName,
            Status = MapStageStatus(stageState, stageResult),
            Duration = ComputeDuration(stageRecord.Value),
            Jobs = [new StageJob { Name = "Steps", Status = MapStageStatus(stageState, stageResult), Duration = ComputeDuration(stageRecord.Value), Steps = steps }]
        };
    }

    public async Task<string?> GetStepLogAsync(int buildId, int logId, CancellationToken ct = default)
    {
        var url = $"{BaseUrl}/build/builds/{buildId}/logs/{logId}?api-version=7.1";

        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        var credentials = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{Pat}"));
        request.Headers.Authorization = new AuthenticationHeaderValue("Basic", credentials);

        var response = await httpClient.SendAsync(request, ct);
        if (!response.IsSuccessStatusCode)
        {
            logger.LogWarning("ADO Logs API returned {StatusCode} for build {BuildId} log {LogId}", (int)response.StatusCode, buildId, logId);
            return null;
        }

        return await response.Content.ReadAsStringAsync(ct);
    }

    private static bool MatchesStageName(string? recordName, string stageName) => stageName switch
    {
        "build" => recordName is "Build" or "Build App",
        "test" => recordName is "UnitTest" or "Unit Tests",
        "scan" => recordName is "Scan" or "Scan App",
        "infraDeploy" => recordName is "DeployInfra" or "Deploy Infrastructure",
        "appDeploy" => recordName is "Deploy" or "Deploy App",
        "integrationTest" => recordName is "IntegrationTest" or "Integration Tests",
        _ => false
    };

    private static string? ComputeDuration(JsonElement record)
    {
        var start = record.TryGetProperty("startTime", out var st) && st.ValueKind != JsonValueKind.Null
            ? st.GetDateTime() : (DateTime?)null;
        var finish = record.TryGetProperty("finishTime", out var ft) && ft.ValueKind != JsonValueKind.Null
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
            "failed" => "Failed",
            "canceled" => "Canceled",
            _ => "Failed"
        },
        "inProgress" => "Running",
        "canceling" => "Canceled",
        "notStarted" => "Running",
        _ => "Running"
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
        bool build, bool tests, bool scan, bool deploy, bool integrations,
        string deployInfra, CancellationToken ct = default)
    {
        var url = $"https://dev.azure.com/{Org}/{Project}/_apis/pipelines/{OrchestratorPipelineId}/runs?api-version=7.1";

        var payload = new
        {
            templateParameters = new Dictionary<string, string>
            {
                ["repo"] = repo,
                ["branch"] = branch,
                ["config"] = config,
                ["environment"] = environment,
                ["build"] = build.ToString(),
                ["tests"] = tests.ToString(),
                ["scan"] = scan.ToString(),
                ["deploy"] = deploy.ToString(),
                ["integrations"] = integrations.ToString(),
                ["deployInfra"] = deployInfra
            }
        };

        var json = JsonSerializer.Serialize(payload);

        using var request = new HttpRequestMessage(HttpMethod.Post, url);
        var credentials = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{Pat}"));
        request.Headers.Authorization = new AuthenticationHeaderValue("Basic", credentials);
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
        request.Headers.Authorization = new AuthenticationHeaderValue("Basic", credentials);
        request.Content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");

        var response = await httpClient.SendAsync(request, ct);

        if (!response.IsSuccessStatusCode)
        {
            var body = await response.Content.ReadAsStringAsync(ct);
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
        request.Headers.Authorization = new AuthenticationHeaderValue("Basic", credentials);

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
