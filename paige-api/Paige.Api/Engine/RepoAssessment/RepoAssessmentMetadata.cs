namespace Paige.Api.Engine.RepoAssessment;

public sealed class RepoAssessmentMetadata
{
    public string RepoName { get; set; } = null!;

    public string Branch { get; set; } = null!;

    public string CommitSha { get; set; } = null!;
}
