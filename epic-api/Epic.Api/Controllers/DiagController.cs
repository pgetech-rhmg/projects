using Epic.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Epic.Api.Controllers;

/// <summary>
/// Temporary diagnostic endpoints for debugging external API integrations.
/// Remove once integrations are verified working.
/// </summary>
[ApiController]
[Route("api/diag")]
public sealed class DiagController(IAdoService adoService, IGitHubService gitHubService) : ControllerBase
{
    /// <summary>
    /// Test ADO integration — fetch pipeline runs for an app by tag.
    /// </summary>
    [HttpGet("ado/{appName}")]
    public async Task<IActionResult> TestAdo(string appName, CancellationToken ct)
    {
        try
        {
            var runs = await adoService.GetRunsForAppAsync(appName, top: 5, ct: ct);
            return Ok(new { appName, runCount = runs.Count, runs });
        }
        catch (Exception ex)
        {
            return Ok(new { error = ex.Message, type = ex.GetType().Name });
        }
    }

    /// <summary>
    /// Raw ADO tag query — see exactly what the API returns.
    /// </summary>
    [HttpGet("ado-raw/{appName}")]
    public async Task<IActionResult> TestAdoRaw(string appName, CancellationToken ct)
    {
        try
        {
            var pat = HttpContext.RequestServices.GetRequiredService<IConfiguration>()["ADO_PAT"];
            if (string.IsNullOrEmpty(pat))
                return Ok(new { error = "ADO_PAT not configured" });

            var url = $"https://dev.azure.com/pgetech/EPIC-Pipeline/_apis/build/builds?definitions=194&tagFilters={Uri.EscapeDataString(appName)}&$top=5&queryOrder=finishTimeDescending&api-version=7.1";

            using var client = new HttpClient();
            var creds = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{pat}"));
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", creds);

            var response = await client.GetAsync(url, ct);
            var body = await response.Content.ReadAsStringAsync(ct);

            var json = System.Text.Json.JsonDocument.Parse(body).RootElement;
            var builds = json.GetProperty("value").EnumerateArray().Take(2).Select(b =>
            {
                return new
                {
                    id = b.GetProperty("id").GetInt32(),
                    requestedFor = b.TryGetProperty("requestedFor", out var rf)
                        ? rf.GetProperty("displayName").GetString() : null,
                    requestedBy = b.TryGetProperty("requestedBy", out var rb)
                        ? rb.GetProperty("displayName").GetString() : null,
                    hasTriggeredByBuild = b.TryGetProperty("triggeredByBuild", out _),
                    triggeredByBuild = b.TryGetProperty("triggeredByBuild", out var tb)
                        ? tb.ToString() : null,
                    allKeys = b.EnumerateObject().Select(p => p.Name).ToList()
                };
            });

            return Ok(new { requestUrl = url, statusCode = (int)response.StatusCode, builds });
        }
        catch (Exception ex)
        {
            return Ok(new { error = ex.Message, type = ex.GetType().Name });
        }
    }

    /// <summary>
    /// Raw ADO orchestrator query — see requestedFor from the orchestrator pipeline (133).
    /// </summary>
    [HttpGet("ado-orchestrator/{appName}")]
    public async Task<IActionResult> TestAdoOrchestrator(string appName, CancellationToken ct)
    {
        try
        {
            var pat = HttpContext.RequestServices.GetRequiredService<IConfiguration>()["ADO_PAT"];
            if (string.IsNullOrEmpty(pat))
                return Ok(new { error = "ADO_PAT not configured" });

            // No tagFilters — orchestrator isn't tagged. We'll filter by parameters client-side.
            var url = $"https://dev.azure.com/pgetech/EPIC-Pipeline/_apis/build/builds?definitions=133&$top=20&queryOrder=finishTimeDescending&api-version=7.1";

            using var client = new HttpClient();
            var creds = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{pat}"));
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", creds);

            var response = await client.GetAsync(url, ct);
            var body = await response.Content.ReadAsStringAsync(ct);

            var json = System.Text.Json.JsonDocument.Parse(body).RootElement;

            // No filter — just show raw orchestrator builds so we can see what's there
            var builds = json.GetProperty("value").EnumerateArray()
                .Take(5)
                .Select(b =>
                {
                    return new
                    {
                        id = b.GetProperty("id").GetInt32(),
                        buildNumber = b.TryGetProperty("buildNumber", out var bn) ? bn.GetString() : null,
                        status = b.TryGetProperty("status", out var st) ? st.GetString() : null,
                        result = b.TryGetProperty("result", out var res) ? res.GetString() : null,
                        requestedFor = b.TryGetProperty("requestedFor", out var rf)
                            ? rf.GetProperty("displayName").GetString() : null,
                        requestedBy = b.TryGetProperty("requestedBy", out var rb)
                            ? rb.GetProperty("displayName").GetString() : null,
                        reason = b.TryGetProperty("reason", out var r) ? r.GetString() : null,
                        parameters = b.TryGetProperty("parameters", out var p) ? p.GetString() : null,
                        startTime = b.TryGetProperty("startTime", out var st2) ? st2.GetString() : null,
                        finishTime = b.TryGetProperty("finishTime", out var ft) ? ft.GetString() : null
                    };
                });

            return Ok(new { requestUrl = url, statusCode = (int)response.StatusCode, builds });
        }
        catch (Exception ex)
        {
            return Ok(new { error = ex.Message, type = ex.GetType().Name });
        }
    }

    /// <summary>
    /// Test GitHub integration — fetch repo metadata.
    /// </summary>
    [HttpGet("github/{repo}")]
    public async Task<IActionResult> TestGitHub(string repo, CancellationToken ct)
    {
        try
        {
            var info = await gitHubService.GetRepoAsync(repo, ct);
            return Ok(info);
        }
        catch (Exception ex)
        {
            return Ok(new { error = ex.Message, type = ex.GetType().Name });
        }
    }
}
