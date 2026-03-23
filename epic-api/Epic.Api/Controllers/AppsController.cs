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
        var app = await _appService.OnboardAppAsync(request.Repo, request.Branch, ct);
        return CreatedAtAction(nameof(GetApp), new { name = app.Name }, app);
    }

    /// <summary>
    /// Trigger a new pipeline run for an app.
    /// </summary>
    [HttpPost("{name}/runs")]
    [ProducesResponseType(typeof(PipelineRun), 202)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> TriggerRun(string name, [FromBody] TriggerRunRequest request, CancellationToken ct)
    {
        var run = await _appService.TriggerRunAsync(name, request.Branch, request.Environment, ct);
        return Accepted(run);
    }
}
