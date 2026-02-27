using Paige.Api.Engine.PortKey;
using Paige.Api.Engine.RepoAssessment;

namespace Paige.Api.Engine.RepoAssessment.Ai;

public sealed class RepoAssessmentAiService
{
    private readonly IPortKeyExecutionService _portKeyExecutionService;

    public RepoAssessmentAiService(IPortKeyExecutionService portKeyExecutionService)
    {
        _portKeyExecutionService = portKeyExecutionService;
    }

    public async Task<PortKeyExecutionResult> AssessAsync(
        RepoAssessmentResult repoAssessment,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(repoAssessment);

        var prompt = RepoAssessmentAiPrompt.Build(repoAssessment);

        // NOTE: Model selection and routing are handled by the existing PortKey integration.
        return await _portKeyExecutionService.ExecuteAsync(prompt, cancellationToken);
    }
}

