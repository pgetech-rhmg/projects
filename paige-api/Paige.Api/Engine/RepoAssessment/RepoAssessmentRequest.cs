namespace Paige.Api.Engine.RepoAssessment;

public sealed class RepoAssessmentRequest
{
    public string RepoName { get; set; } = null!;

    public string Branch { get; set; } = "main";
}
