using System.Net.Http.Headers;
using System.Text.Json;
using Epic.Api.Models;

namespace Epic.Api.Services;

public sealed class AdoService(HttpClient httpClient, IConfiguration configuration) : IAdoService
{
    private const string Org = "pgetech";
    private const string Project = "EPIC-Pipeline";
    private const int EnginePipelineId = 194;

    private string Pat =>
        configuration["ADO_PAT"]
        ?? throw new InvalidOperationException("ADO_PAT not configured.");

    private string BaseUrl => $"https://dev.azure.com/{Org}/{Project}/_apis";

    public async Task<List<AdoPipelineRun>> GetRunsForAppAsync(string appName, int top = 20, CancellationToken ct = default)
    {
        // Get recent runs for the engine pipeline
        var runsUrl = $"{BaseUrl}/pipelines/{EnginePipelineId}/runs?api-version=7.1-preview.1";
        var runsJson = await CallApiAsync(runsUrl, ct);

        if (runsJson is null) return [];

        var results = new List<AdoPipelineRun>();

        foreach (var run in runsJson.Value.GetProperty("value").EnumerateArray())
        {
            if (results.Count >= top) break;

            var runId = run.GetProperty("id").GetInt32();

            // Check if this run belongs to the requested app via templateParameters
            var templateParams = run.TryGetProperty("templateParameters", out var tp) ? tp : (JsonElement?)null;
            if (templateParams is null) continue;

            var runAppName = templateParams.Value.TryGetProperty("appName", out var an)
                ? an.GetString() : null;

            if (!string.Equals(runAppName, appName, StringComparison.OrdinalIgnoreCase))
                continue;

            var branch = templateParams.Value.TryGetProperty("branch", out var br)
                ? br.GetString() ?? "" : "";
            var environment = templateParams.Value.TryGetProperty("environment", out var env)
                ? env.GetString() ?? "dev" : "dev";

            var state = run.GetProperty("state").GetString() ?? "";
            var result = run.TryGetProperty("result", out var res) ? res.GetString() : null;

            var status = MapRunStatus(state, result);
            var triggeredBy = run.TryGetProperty("createdBy", out var cb)
                && cb.TryGetProperty("displayName", out var dn)
                ? dn.GetString() ?? "Unknown" : "Unknown";

            var startedAt = run.TryGetProperty("createdDate", out var cd)
                ? cd.GetDateTime() : DateTime.UtcNow;

            var finishedAt = run.TryGetProperty("finishedDate", out var fd)
                && fd.ValueKind != JsonValueKind.Null
                ? fd.GetDateTime() : (DateTime?)null;

            var duration = finishedAt.HasValue
                ? FormatDuration(finishedAt.Value - startedAt)
                : null;

            // Get stage-level results from the timeline
            var stages = await GetStageResultsAsync(runId, ct);

            results.Add(new AdoPipelineRun
            {
                Id = runId,
                Status = status,
                TriggeredBy = triggeredBy,
                Branch = branch,
                Environment = environment,
                StartedAt = startedAt,
                Duration = duration,
                Stages = stages
            });
        }

        return results;
    }

    private async Task<PipelineStages> GetStageResultsAsync(int buildId, CancellationToken ct)
    {
        var timelineUrl = $"{BaseUrl}/build/builds/{buildId}/timeline?api-version=7.1";
        var timelineJson = await CallApiAsync(timelineUrl, ct);

        var stages = new PipelineStages
        {
            Build = RunStatus.Skipped,
            Test = RunStatus.Skipped,
            Scan = RunStatus.Skipped,
            InfraDeploy = RunStatus.Skipped,
            AppDeploy = RunStatus.Skipped
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
            }
        }

        return stages;
    }

    private static string MapRunStatus(string state, string? result) => state switch
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
            "pending" => RunStatus.Skipped,
            _ => RunStatus.Skipped
        };
    }

    private static string FormatDuration(TimeSpan ts)
    {
        if (ts.TotalHours >= 1) return $"{(int)ts.TotalHours}h {ts.Minutes}m";
        return $"{ts.Minutes}m {ts.Seconds:D2}s";
    }

    private async Task<JsonElement?> CallApiAsync(string url, CancellationToken ct)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        var credentials = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{Pat}"));
        request.Headers.Authorization = new AuthenticationHeaderValue("Basic", credentials);

        var response = await httpClient.SendAsync(request, ct);

        if (!response.IsSuccessStatusCode) return null;

        var body = await response.Content.ReadAsStringAsync(ct);
        return JsonDocument.Parse(body).RootElement;
    }
}
