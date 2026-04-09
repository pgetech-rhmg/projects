using Epic.Api.Models;
using Epic.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Epic.Api.Controllers;

[ApiController]
[Route("api/apps")]
public sealed class AppsController : ControllerBase
{
    private readonly IAppService _appService;

    public AppsController(IAppService appService)
    {
        _appService = appService;
    }

    /// <summary>
    /// Get full detail for an app including pipeline run history.
    /// </summary>
    [HttpGet("{name}")]
    [ProducesResponseType(typeof(AppDetail), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetApp(string name, CancellationToken ct)
    {
        var app = await _appService.GetAppAsync(name, ct);
        if (app is null) return NotFound();
        return Ok(app);
    }

    /// <summary>
    /// Get a paged slice of pipeline runs for an app, with the total run count.
    /// </summary>
    [HttpGet("{name}/runs")]
    [ProducesResponseType(typeof(PipelineRunPage), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetRuns(string name, [FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken ct = default)
    {
        var result = await _appService.GetRunsPageAsync(name, page, pageSize, ct);
        if (result is null) return NotFound();
        return Ok(result);
    }

    /// <summary>
    /// Check if a GitHub repo can be onboarded into EPIC.
    /// </summary>
    [HttpGet("check")]
    [ProducesResponseType(typeof(RepoCheckResult), 200)]
    [ProducesResponseType(400)]
    public async Task<IActionResult> CheckRepo([FromQuery] string repo, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(repo))
            return BadRequest(new { error = "repo query parameter is required" });

        var result = await _appService.CheckRepoAsync(repo, ct);
        return Ok(result);
    }

    /// <summary>
    /// Onboard a new application into EPIC.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(AppDetail), 201)]
    [ProducesResponseType(400)]
    public async Task<IActionResult> OnboardApp([FromBody] OnboardAppRequest request, CancellationToken ct)
    {
        try
        {
            var app = await _appService.OnboardAppAsync(request.Repo, request.Branch, ct);
            return CreatedAtAction(nameof(GetApp), new { name = app.Name }, app);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { error = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Trigger a new pipeline run for an app.
    /// </summary>
    [HttpPost("{name}/runs")]
    [ProducesResponseType(typeof(TriggerRunResponse), 202)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> TriggerRun(string name, [FromBody] TriggerRunRequest request, CancellationToken ct)
    {
        try
        {
            var result = await _appService.TriggerRunAsync(
                name, request.Branch, request.Environment,
                request.Build, request.Tests, request.Scan,
                request.Deploy, request.Integrations, request.DeployInfra, ct);
            return Accepted(result);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    /// <summary>
    /// Cancel a running pipeline build.
    /// </summary>
    [HttpPost("{name}/runs/{runId:int}/cancel")]
    [ProducesResponseType(204)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> CancelRun(string name, int runId, CancellationToken ct)
    {
        try
        {
            await _appService.CancelRunAsync(name, runId, ct);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }
}
