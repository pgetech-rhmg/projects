namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class RepositoryProjectNode
{
    public string Id { get; set; } = Guid.NewGuid().ToString();

    public string Name { get; set; } = "";

    public string RelativePath { get; set; } = "";

    public string ProjectType { get; set; } = "";

    public string? Framework { get; set; }

    public List<string> FilePaths { get; set; } = [];

    public ProjectMetrics Metrics { get; set; } = new();

    public List<ProjectDependency> Dependencies { get; set; } = [];

    public ProjectDependencySummary DependencySummary { get; set; } = new();

    public ProjectStructuralSignals StructuralSignals { get; set; } = new();

    public ProjectArchitectureSignals ArchitectureSignals { get; set; } = new();

    public ModernizationSignals ModernizationSignals { get; set; } =
        new(
            RuntimePlatform.Unknown,
            RuntimeGeneration.Unknown,
            "unknown",
            null,
            FrameworkSupportStatus.Unknown);
}

