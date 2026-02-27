namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class ProjectArchitectureSignals
{
    public bool HasTests { get; set; }

    public int TestFileCount { get; set; }

    public double? TestToSourceRatio { get; set; }

    public List<string> TestFrameworks { get; set; } = [];

    public bool ContainsDocker { get; set; }

    public bool ContainsCICD { get; set; }

    public bool ContainsInfrastructureCode { get; set; }

    public bool IsApiProject { get; set; }

    public bool IsLibraryProject { get; set; }
}

public sealed class RepositoryArchitectureSignals
{
    public bool HasDocker { get; set; }

    public bool HasCICD { get; set; }

    public bool HasInfrastructureLayer { get; set; }

    public int ProjectsWithTestsCount { get; set; }

    public int ApiProjectCount { get; set; }

    public int LibraryProjectCount { get; set; }

    public List<string> DistinctTestFrameworks { get; set; } = [];
}

