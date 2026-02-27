namespace Paige.Api.Engine.RepoAssessment;

public interface IRepoAssessmentService
{
    Task<RepoAssessmentResult> ScanAsync(
        RepoAssessmentRequest request,
        CancellationToken cancellationToken);
}
