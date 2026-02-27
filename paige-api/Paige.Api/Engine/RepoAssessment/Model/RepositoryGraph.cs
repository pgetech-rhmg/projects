namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class RepositoryGraph
{
    public RepositoryMetadata Metadata { get; set; } = new();

    public RepositoryMetrics Metrics { get; set; } = new();

    public List<RepositoryFileNode> Files { get; set; } = [];

    public List<RepositoryProjectNode> Projects { get; set; } = [];

    public List<DetectedTechnology> DetectedTechnologies { get; set; } = [];

    public RepositoryDependencySummary DependencySummary { get; set; } = new();

    public RepositoryStructuralSignals StructuralSignals { get; set; } = new();

    public RepositoryArchitectureSignals ArchitectureSignals { get; set; } = new();

    public List<ModernizationSignals> ModernizationSignals { get; set; } = [];
}

