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
