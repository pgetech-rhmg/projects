using Microsoft.AspNetCore.Mvc;

using Paige.Api.Engine.CfnConverter.Scan;

namespace Paige.Api.Controllers;

[ApiController]
[Route("api/scan")]
public sealed class RepoScanController : ControllerBase
{
    private readonly IRepoScanService _repoScanService;

    public RepoScanController(IRepoScanService repoScanService)
    {
        _repoScanService = repoScanService;
    }

    [HttpPost("repo")]
    [ProducesResponseType(typeof(RepoScanResult), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> ScanAsync([FromBody] RepoScanRequest request, CancellationToken cancellationToken)
    {
        if (request == null)
        {
            return BadRequest("Request body is required.");
        }

        if (string.IsNullOrWhiteSpace(request.RepoName))
        {
            return BadRequest("RepoName is required.");
        }

        try
        {
            RepoScanResult result = await _repoScanService.ScanAsync(request, cancellationToken);

            return Ok(result);
        }
        catch (OperationCanceledException)
        {
            return StatusCode(StatusCodes.Status499ClientClosedRequest, "Request was cancelled.");
        }
        catch (Exception ex)
        {
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new
                {
                    error = "Repo scan failed.",
                    detail = ex.Message
                });
        }
    }
}
