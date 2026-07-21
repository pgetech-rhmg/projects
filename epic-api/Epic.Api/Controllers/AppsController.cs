using Epic.Api.Models;
using Epic.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Epic.Api.Controllers;

[ApiController]
[Route("api/apps")]
public sealed class AppsController : ControllerBase
{
    private readonly IAppService _appService;
    private readonly IGitHubSourceRegistry _sources;

    public AppsController(IAppService appService, IGitHubSourceRegistry sources)
    {
        _appService = appService;
        _sources = sources;
    }

    /// <summary>
    /// List the configured GitHub sources (org + name) the New App flow can pick
    /// from, and which one is the default. Names, not tokens.
    /// </summary>
    [HttpGet("github-sources")]
    [ProducesResponseType(200)]
    public IActionResult GetGitHubSources()
    {
        var defaultName = _sources.Default.Name;
        var sources = _sources.All
            .Select(s => new { name = s.Name, org = s.Org, isDefault = s.Name == defaultName })
            .ToList();
        return Ok(new { sources, defaultSource = defaultName });
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
    /// URL of the SonarQube dashboard for a run's Scan stage, parsed from the
    /// "Analyze code" step log. 404 when the scan wasn't SonarQube or no URL was
    /// emitted (failed/non-terminal scan, or Wiz).
    /// </summary>
    [HttpGet("{name}/runs/{runId:int}/scan-result-url")]
    [ProducesResponseType(200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetScanResultUrl(string name, int runId, CancellationToken ct)
    {
        var url = await _appService.GetScanResultUrlAsync(name, runId, ct);
        if (url is null) return NotFound();
        return Ok(new { url });
    }

    /// <summary>
    /// Download the Markdown compliance report produced by the Review stage.
    /// </summary>
    [HttpGet("{name}/runs/{runId:int}/compliance-report")]
    [ProducesResponseType(typeof(string), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetComplianceReport(string name, int runId, CancellationToken ct)
    {
        var report = await _appService.GetComplianceReportAsync(name, runId, ct);
        if (report is null) return NotFound();
        return Ok(new { report });
    }

    /// <summary>
    /// Summary of the structured compliance report (tool version + verdict
    /// counts) produced by the Review stage, for inline display in the dashboard.
    /// </summary>
    [HttpGet("{name}/runs/{runId:int}/compliance-summary")]
    [ProducesResponseType(typeof(ComplianceSummary), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetComplianceSummary(string name, int runId, CancellationToken ct)
    {
        var summary = await _appService.GetComplianceSummaryAsync(name, runId, ct);
        if (summary is null) return NotFound();
        return Ok(summary);
    }

    /// <summary>
    /// Full structured compliance report (summary + profile + findings) from the
    /// Review stage, for native in-app rendering.
    /// </summary>
    [HttpGet("{name}/runs/{runId:int}/compliance-report-json")]
    [ProducesResponseType(typeof(ComplianceReport), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetComplianceReportJson(string name, int runId, CancellationToken ct)
    {
        var report = await _appService.GetComplianceReportJsonAsync(name, runId, ct);
        if (report is null) return NotFound();
        return Ok(report);
    }

    /// <summary>
    /// Check if a GitHub repo can be onboarded into EPIC.
    /// </summary>
    [HttpGet("check")]
    [ProducesResponseType(typeof(RepoCheckResult), 200)]
    [ProducesResponseType(400)]
    public async Task<IActionResult> CheckRepo([FromQuery] string repo, [FromQuery] string? source, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(repo))
            return BadRequest(new { error = "repo query parameter is required" });

        var result = await _appService.CheckRepoAsync(repo, source, ct);
        return Ok(result);
    }

    /// <summary>
    /// Find all epic.json config files in a repo/branch.
    /// </summary>
    [HttpGet("configs")]
    [ProducesResponseType(200)]
    [ProducesResponseType(400)]
    public async Task<IActionResult> FindConfigs([FromQuery] string repo, [FromQuery] string branch, [FromQuery] string? source, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(repo) || string.IsNullOrWhiteSpace(branch))
            return BadRequest(new { error = "repo and branch query parameters are required" });

        var configs = await _appService.FindConfigsAsync(repo, branch, source, ct);
        return Ok(new { configs });
    }

    /// <summary>
    /// Check if a specific config has infrastructure (reads infraPath from the file).
    /// </summary>
    [HttpGet("configs/check")]
    [ProducesResponseType(200)]
    [ProducesResponseType(400)]
    public async Task<IActionResult> CheckConfigInfra([FromQuery] string repo, [FromQuery] string branch, [FromQuery] string config, [FromQuery] string? source, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(repo) || string.IsNullOrWhiteSpace(branch) || string.IsNullOrWhiteSpace(config))
            return BadRequest(new { error = "repo, branch, and config query parameters are required" });

        var result = await _appService.CheckConfigInfraAsync(repo, branch, config, source, ct);
        return Ok(new
        {
            hasInfra = result.HasInfra,
            hasInfraParams = result.HasInfraParams,
            appType = result.AppType,
            buildTestTool = result.BuildTestTool,
            scanTool = result.ScanTool,
            integrationTestTool = result.IntegrationTestTool,
            hasS3Backend = result.HasS3Backend,
            hasTfState = result.HasTfState
        });
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
            var app = await _appService.OnboardAppAsync(request.Repo, request.Source, ct);
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
                request.ReviewOrDefault, request.BuildOrDefault, request.TestsOrDefault, request.ScanOrDefault,
                request.DeployOrDefault, request.IntegrationsOrDefault, request.DeployInfra,
                request.ForceStateCopyOrDefault, ct);
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
