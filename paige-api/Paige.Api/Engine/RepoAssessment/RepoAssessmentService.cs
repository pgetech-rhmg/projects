using Microsoft.Extensions.Options;

using Paige.Api.Engine.Common;
using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment;

public sealed class RepoAssessmentService : IRepoAssessmentService
{
    private readonly Config _config;
    private readonly IRepoCloner _repoCloner;
    private readonly RepositoryGraphBuilder _graphBuilder;
    private readonly IRepoStructureAnalyzer _analyzer;

    public RepoAssessmentService(
        IOptions<Config> config,
        IRepoCloner repoCloner,
        RepositoryGraphBuilder graphBuilder,
        IRepoStructureAnalyzer analyzer)
    {
        _config = config.Value;
        _repoCloner = repoCloner;
        _graphBuilder = graphBuilder;
        _analyzer = analyzer;
    }

    public async Task<RepoAssessmentResult> ScanAsync(
        RepoAssessmentRequest request,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        // Clone repo
        ClonedRepo clonedRepo = await _repoCloner.CloneAsync(
            $"{_config.GithubBaseUrl}/{request.RepoName}",
            request.Branch,
            _config.GithubToken,
            cancellationToken);

        // Build deterministic repository graph (no content)
        RepositoryGraph graph = _graphBuilder.Build(clonedRepo.LocalPath);

        // Placeholder for future "skip if unchanged" logic
        // (Persistence check will be added later)
        if (IsRepositoryUnchanged(graph.Metadata.RepositoryHash))
        {
            return new RepoAssessmentResult
            {
                Repo = new RepoAssessmentMetadata
                {
                    RepoName = request.RepoName,
                    Branch = request.Branch,
                    CommitSha = clonedRepo.CommitSha
                },
                RepositoryHash = graph.Metadata.RepositoryHash,
                IsUnchanged = true,
                Message = "Repository has not changed since last assessment.",
                RepositoryGraph = graph
            };
        }

        // Run existing structure analyzer (still using file content for now)
        // We intentionally scan WITH content here because analyzer expects it.
        IReadOnlyList<ScannedFile> scannedFiles =
            _graphBuilder is not null
                ? new FileScanner().Scan(clonedRepo.LocalPath, includeContent: true)
                : throw new InvalidOperationException("FileScanner required for structure analysis.");

        RepoStructureSummary structure = _analyzer.Analyze(request.RepoName, request.Branch, scannedFiles);

        // Return enriched result
        return new RepoAssessmentResult
        {
            Repo = new RepoAssessmentMetadata
            {
                RepoName = request.RepoName,
                Branch = request.Branch,
                CommitSha = clonedRepo.CommitSha
            },
            RepositoryHash = graph.Metadata.RepositoryHash,
            IsUnchanged = false,
            Summary = new RepoAssessmentSummary
            {
                FilesScanned = graph.Metrics.TotalFiles,
                Structure = structure
            },
            RepositoryGraph = graph
        };
    }

    private static bool IsRepositoryUnchanged(string repositoryHash)
    {
        // TODO: Replace with persistent lookup in Step 5
        return false;
    }
}

