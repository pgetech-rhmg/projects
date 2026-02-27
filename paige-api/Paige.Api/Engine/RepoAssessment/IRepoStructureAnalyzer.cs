using Paige.Api.Engine.Common;

namespace Paige.Api.Engine.RepoAssessment;

public interface IRepoStructureAnalyzer
{
    public RepoStructureSummary Analyze(
        string repoName,
        string branch,
        IReadOnlyCollection<ScannedFile> files);
}
