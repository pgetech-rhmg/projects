using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment;

public sealed class RepoAssessmentResult
{
    public RepoAssessmentMetadata Repo { get; set; } = null!;

    public RepoAssessmentSummary Summary { get; set; } = null!;

    public string RepositoryHash { get; set; } = "";

    public bool IsUnchanged { get; set; }

    public string? Message { get; set; }

    public RepositoryGraph? RepositoryGraph { get; set; }

}
