namespace Paige.Api.Engine.RepoAssessment;

public sealed class RepoAssessmentSummary
{
    public int FilesScanned { get; set; }

    public RepoStructureSummary? Structure { get; set; } = null;
}
