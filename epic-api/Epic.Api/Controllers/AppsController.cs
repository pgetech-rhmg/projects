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
    /// Get job/step detail for a specific stage of a pipeline run.
    /// </summary>
    [HttpGet("{name}/runs/{runId:int}/stages/{stageName}")]
    [ProducesResponseType(typeof(StageDetail), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetStageDetail(string name, int runId, string stageName, CancellationToken ct)
    {
        var detail = await _appService.GetStageDetailAsync(name, runId, stageName, ct);
        if (detail is null) return NotFound();
        return Ok(detail);
    }

    /// <summary>
    /// Get the raw log text for a specific step of a pipeline run.
    /// </summary>
    [HttpGet("{name}/runs/{runId:int}/logs/{logId:int}")]
    [ProducesResponseType(typeof(string), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetStepLog(string name, int runId, int logId, CancellationToken ct)
    {
        var log = await _appService.GetStepLogAsync(name, runId, logId, ct);
        if (log is null) return NotFound();
        return Ok(new { log });
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
    /// Find all epic.json config files in a repo/branch.
    /// </summary>
    [HttpGet("configs")]
    [ProducesResponseType(200)]
    [ProducesResponseType(400)]
    public async Task<IActionResult> FindConfigs([FromQuery] string repo, [FromQuery] string branch, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(repo) || string.IsNullOrWhiteSpace(branch))
            return BadRequest(new { error = "repo and branch query parameters are required" });

        var configs = await _appService.FindConfigsAsync(repo, branch, ct);
        return Ok(new { configs });
    }

    /// <summary>
    /// Check if a specific config has infrastructure (reads infraPath from the file).
    /// </summary>
    [HttpGet("configs/check")]
    [ProducesResponseType(200)]
    [ProducesResponseType(400)]
    public async Task<IActionResult> CheckConfigInfra([FromQuery] string repo, [FromQuery] string branch, [FromQuery] string config, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(repo) || string.IsNullOrWhiteSpace(branch) || string.IsNullOrWhiteSpace(config))
            return BadRequest(new { error = "repo, branch, and config query parameters are required" });

        var result = await _appService.CheckConfigInfraAsync(repo, branch, config, ct);
        return Ok(new { hasInfra = result.HasInfra, hasInfraParams = result.HasInfraParams, appType = result.AppType });
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
            var app = await _appService.OnboardAppAsync(request.Repo, ct);
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
                name, request.Branch, request.Environment, request.Config,
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
