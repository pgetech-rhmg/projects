namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class ProjectDependency
{
    public string Ecosystem { get; set; } = "";
    // dotnet, node, python, java, go

    public string Name { get; set; } = "";

    public string? Version { get; set; }
    // Exact version when provided (e.g., 1.2.3)

    public string? VersionSpec { get; set; }
    // Raw spec when not exact (e.g., ^1.2.3, >=2.0)

    public string? Group { get; set; }
    // Java groupId, when applicable

    public string? Scope { get; set; }
    // dev, test, compile, runtime, provided, etc.

    public string SourceManifestPath { get; set; } = "";
}

