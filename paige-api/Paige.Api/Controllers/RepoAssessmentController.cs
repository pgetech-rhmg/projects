using Microsoft.AspNetCore.Mvc;
using Paige.Api.Engine.PortKey;
using Paige.Api.Engine.RepoAssessment;
using Paige.Api.Engine.RepoAssessment.Ai;

namespace Paige.Api.Controllers;

[ApiController]
[Route("api/repo")]
public sealed class RepoAssessmentController : ControllerBase
{
    private readonly IRepoAssessmentService _repoAssessmentService;
    private readonly RepoAssessmentAiService _repoAssessmentAiService;

    public RepoAssessmentController(
        IRepoAssessmentService repoAssessmentService,
        RepoAssessmentAiService repoAssessmentAiService)
    {
        _repoAssessmentService = repoAssessmentService;
        _repoAssessmentAiService = repoAssessmentAiService;
    }

    [HttpPost("assess")]
    [ProducesResponseType(typeof(RepoAssessmentResult), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status499ClientClosedRequest)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> ScanAsync(
        [FromBody] RepoAssessmentRequest request,
        CancellationToken cancellationToken)
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
            RepoAssessmentResult repoAssessment = await _repoAssessmentService.ScanAsync(request, cancellationToken);

            return Ok(repoAssessment);
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


    [HttpPost("analyze")]
    [ProducesResponseType(typeof(PortKeyExecutionResult), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status499ClientClosedRequest)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> AnalyzeAsync(
        [FromBody] RepoAssessmentResult request,
        CancellationToken cancellationToken)
    {
        if (request == null)
        {
            return BadRequest("Request body is required.");
        }

        try
        {
            request.RepositoryGraph!.Files = [];
            request.RepositoryGraph!.Projects = [];

            var aiAssessment = await _repoAssessmentAiService.AssessAsync(request, cancellationToken);

            return Ok(aiAssessment);
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

