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
        var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString(appName)}&$top={top}&queryOrder=queueTimeDescending&api-version=7.1";
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

            // Extract branch and environment from the build's parameters
            var branch = "";
            var environment = "dev";
            var paramsString = build.TryGetProperty("parameters", out var p) && p.ValueKind == JsonValueKind.String
                ? p.GetString() : null;
            if (paramsString is not null)
            {
                try
                {
                    var paramObj = JsonDocument.Parse(paramsString).RootElement;
                    branch = paramObj.TryGetProperty("branch", out var br) ? br.GetString() ?? "" : "";
                    environment = paramObj.TryGetProperty("environment", out var env) ? env.GetString() ?? "dev" : "dev";
                }
                catch (Exception ex) { logger.LogDebug(ex, "ADO build parameters not parseable — using defaults"); }
            }

            // Fall back to source branch if parameters didn't have it
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
        var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString(appName)}&$top={top}&queryOrder=queueTimeDescending&api-version=7.1";
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

            // Extract branch and environment from the build's parameters
            var branch = "";
            var environment = "dev";
            var paramsString = build.TryGetProperty("parameters", out var p) && p.ValueKind == JsonValueKind.String
                ? p.GetString() : null;
            if (paramsString is not null)
            {
                try
                {
                    var paramObj = JsonDocument.Parse(paramsString).RootElement;
                    branch = paramObj.TryGetProperty("branch", out var br) ? br.GetString() ?? "" : "";
                    environment = paramObj.TryGetProperty("environment", out var env) ? env.GetString() ?? "dev" : "dev";
                }
                catch (Exception ex) { logger.LogDebug(ex, "ADO build parameters not parseable — using defaults"); }
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

            results.Add(new AdoLatestRun
            {
                Id = build.GetProperty("id").GetInt32(),
                Status = MapRunStatus(adoStatus, adoResult),
                TriggeredBy = triggeredBy,
                Branch = branch,
                Environment = environment,
                StartedAt = startedAt,
                Duration = finishedAt.HasValue ? FormatDuration(finishedAt.Value - startedAt) : null
            });
        }

        // Resolve real triggeredBy from orchestrator pipeline (single bulk call)
        await ResolveTriggeredByFromOrchestratorAsync(appName, results, ct);

        return results;
    }

    /// <summary>
    /// Counts ALL completed runs for an app — total and successful — by paginating
    /// through every build with the appName tag. In-progress runs are excluded by
    /// the server-side statusFilter, so the totals reflect lifetime success rate.
    /// Cost: 1 ADO call per 1000 runs (typically just 1).
    /// </summary>
    public async Task<(int Total, int Successful)> GetCompletedRunCountsAsync(string appName, CancellationToken ct = default)
    {
        var total = 0;
        var successful = 0;
        string? continuationToken = null;
        const int pageSize = 1000;

        do
        {
            var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString(appName)}&statusFilter=completed&$top={pageSize}&queryOrder=queueTimeDescending&api-version=7.1";
            if (continuationToken is not null)
                url += $"&continuationToken={Uri.EscapeDataString(continuationToken)}";

            var (json, nextToken) = await CallApiWithContinuationAsync(url, ct);
            if (json is null) break;

            foreach (var build in json.Value.GetProperty("value").EnumerateArray())
            {
                total++;
                var result = build.TryGetProperty("result", out var r) ? r.GetString() : null;
                if (result == "succeeded") successful++;
            }

            continuationToken = nextToken;
        } while (!string.IsNullOrEmpty(continuationToken));

        return (total, successful);
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
            var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString(appName)}&$top={pageSize}&queryOrder=queueTimeDescending&api-version=7.1";
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
            var url = $"{BaseUrl}/build/builds?definitions={EnginePipelineId}&tagFilters={Uri.EscapeDataString(appName)}&$top={pageSize}&queryOrder=queueTimeDescending&api-version=7.1";
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

            await ResolveTriggeredByFromOrchestratorAsync(appName, results, ct);
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
        var paramsString = build.TryGetProperty("parameters", out var p) && p.ValueKind == JsonValueKind.String
            ? p.GetString() : null;
        if (paramsString is not null)
        {
            try
            {
                var paramObj = JsonDocument.Parse(paramsString).RootElement;
                branch = paramObj.TryGetProperty("branch", out var br) ? br.GetString() ?? "" : "";
                environment = paramObj.TryGetProperty("environment", out var env) ? env.GetString() ?? "dev" : "dev";
            }
            catch (Exception ex) { logger.LogDebug(ex, "ADO build parameters not parseable — using defaults"); }
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

        var duration = finishedAt.HasValue ? FormatDuration(finishedAt.Value - startedAt) : null;

        var stages = includeStages
            ? await GetStageResultsAsync(buildId, isTerminal: status != "Running", ct)
            : new PipelineStages
            {
                Build = RunStatus.Skipped,
                Test = RunStatus.Skipped,
                Scan = RunStatus.Skipped,
                InfraDeploy = RunStatus.Skipped,
                AppDeploy = RunStatus.Skipped,
                IntegrationTest = RunStatus.Skipped
            };

        return new AdoPipelineRun
        {
            Id = buildId,
            Status = status,
            TriggeredBy = triggeredBy,
            Branch = branch,
            Environment = environment,
            StartedAt = startedAt,
            Duration = duration,
            Stages = stages
        };
    }

    /// <summary>
    /// Queries orchestrator builds (tagged with appName) and matches each engine run
    /// to its orchestrator run by time proximity, overriding TriggeredBy with the real user.
    /// </summary>
    private Task ResolveTriggeredByFromOrchestratorAsync(string appName, List<AdoPipelineRun> engineRuns, CancellationToken ct) =>
        ResolveTriggeredByFromOrchestratorCoreAsync(
            appName,
            engineRuns.Count,
            engineRuns.Select(r => (r.StartedAt, (Action<string>)(s => r.TriggeredBy = s))).ToList(),
            ct);

    private Task ResolveTriggeredByFromOrchestratorAsync(string appName, List<AdoLatestRun> engineRuns, CancellationToken ct) =>
        ResolveTriggeredByFromOrchestratorCoreAsync(
            appName,
            engineRuns.Count,
            engineRuns.Select(r => (r.StartedAt, (Action<string>)(s => r.TriggeredBy = s))).ToList(),
            ct);

    private async Task ResolveTriggeredByFromOrchestratorCoreAsync(
        string appName,
        int totalRuns,
        List<(DateTime StartedAt, Action<string> SetTriggeredBy)> engineRuns,
        CancellationToken ct)
    {
        if (totalRuns == 0) return;

        var url = $"{BaseUrl}/build/builds?definitions={OrchestratorPipelineId}&tagFilters={Uri.EscapeDataString(appName)}&$top={totalRuns + 5}&queryOrder=finishTimeDescending&api-version=7.1";
        var json = await CallApiAsync(url, ct);
        if (json is null) return;

        var orchRuns = json.Value.GetProperty("value").EnumerateArray()
            .Select(b =>
            {
                var ft = b.TryGetProperty("finishTime", out var f) && f.ValueKind != JsonValueKind.Null
                    ? f.GetDateTime() : (DateTime?)null;
                var reqFor = b.TryGetProperty("requestedFor", out var rf)
                    && rf.TryGetProperty("displayName", out var dn)
                    ? dn.GetString() : null;
                return new { FinishTime = ft, RequestedFor = reqFor };
            })
            .Where(o => o.FinishTime.HasValue && o.RequestedFor is not null)
            .OrderByDescending(o => o.FinishTime)
            .ToList();

        if (orchRuns.Count == 0) return;

        foreach (var run in engineRuns)
        {
            // Find the orchestrator build that finished closest to (and before) the engine's start time
            var match = orchRuns
                .Where(o => o.FinishTime!.Value <= run.StartedAt.AddSeconds(30))
                .MinBy(o => run.StartedAt - o.FinishTime!.Value);

            if (match?.RequestedFor is not null)
                run.SetTriggeredBy(match.RequestedFor);
        }
    }

    private async Task<PipelineStages> GetStageResultsAsync(int buildId, bool isTerminal, CancellationToken ct)
    {
        var cacheKey = $"timeline:{buildId}";
        // Only completed builds are safe to cache — running builds' stages still change.
        if (isTerminal && cache.TryGetValue(cacheKey, out PipelineStages? cached) && cached is not null)
            return cached;

        var url = $"{BaseUrl}/build/builds/{buildId}/timeline?api-version=7.1";
        var timelineJson = await CallApiAsync(url, ct);

        var stages = new PipelineStages
        {
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

        if (isTerminal)
        {
            cache.Set(cacheKey, stages, new MemoryCacheEntryOptions
            {
                SlidingExpiration = TimelineCacheTtl,
                Size = 1
            });
        }

        return stages;
    }

    private static string MapRunStatus(string? state, string? result) => state switch
    {
        "completed" => result switch
        {
            "succeeded" => "Success",
            "failed" => "Failed",
            "canceled" => "Cancelled",
            _ => "Failed"
        },
        "inProgress" => "Running",
        "canceling" => "Cancelled",
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
                "canceled" or "cancelled" => RunStatus.Cancelled,
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
        string repo, string branch, string environment,
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
