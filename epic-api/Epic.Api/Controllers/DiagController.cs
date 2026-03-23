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
    /// Test ADO integration — fetch pipeline runs for an app.
    /// </summary>
    [HttpGet("ado/{appName}")]
    public async Task<IActionResult> TestAdo(string appName, CancellationToken ct)
    {
        try
        {
            var runs = await adoService.GetRunsForAppAsync(appName, 5, ct);
            return Ok(new
            {
                appName,
                runCount = runs.Count,
                runs
            });
        }
        catch (Exception ex)
        {
            return Ok(new { error = ex.Message, type = ex.GetType().Name });
        }
    }

    /// <summary>
    /// Raw ADO builds response — see exactly what the API returns.
    /// </summary>
    [HttpGet("ado-raw")]
    public async Task<IActionResult> TestAdoRaw(CancellationToken ct)
    {
        try
        {
            var pat = HttpContext.RequestServices.GetRequiredService<IConfiguration>()["ADO_PAT"];
            if (string.IsNullOrEmpty(pat))
                return Ok(new { error = "ADO_PAT not configured" });

            var url = "https://dev.azure.com/pgetech/EPIC-Pipeline/_apis/build/builds?definitions=194&$top=5&queryOrder=finishTimeDescending&api-version=7.1";

            using var client = new HttpClient();
            var creds = Convert.ToBase64String(System.Text.Encoding.ASCII.GetBytes($":{pat}"));
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", creds);

            var response = await client.GetAsync(url, ct);
            var body = await response.Content.ReadAsStringAsync(ct);

            // Return first 2 builds with their parameters field
            var json = System.Text.Json.JsonDocument.Parse(body).RootElement;
            var builds = json.GetProperty("value").EnumerateArray().Take(2).Select(b => new
            {
                id = b.GetProperty("id").GetInt32(),
                status = b.TryGetProperty("status", out var s) ? s.GetString() : null,
                result = b.TryGetProperty("result", out var r) ? r.GetString() : null,
                hasParameters = b.TryGetProperty("parameters", out _),
                parameters = b.TryGetProperty("parameters", out var p) ? p.ToString() : null,
                hasTemplateParameters = b.TryGetProperty("templateParameters", out _),
                templateParameters = b.TryGetProperty("templateParameters", out var tp) ? tp.ToString() : null,
                allKeys = b.EnumerateObject().Select(prop => prop.Name).ToList()
            });

            return Ok(new { statusCode = response.StatusCode, builds });
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
