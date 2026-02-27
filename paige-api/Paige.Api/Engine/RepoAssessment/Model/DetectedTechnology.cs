namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class DetectedTechnology
{
    public string Category { get; set; } = "";
    // language, framework, cloud, test-framework, iac, ci-cd, container, etc.

    public string Name { get; set; } = "";

    public string? Version { get; set; }

    public string DetectionSource { get; set; } = "";
    // file, config, convention, dependency, etc.
}

