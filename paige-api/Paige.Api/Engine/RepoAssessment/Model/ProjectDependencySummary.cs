namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class ProjectDependencySummary
{
    public int TotalDependencyCount { get; set; }

    public int ProdDependencyCount { get; set; }

    public int DevDependencyCount { get; set; }

    public int TestDependencyCount { get; set; }

    public int PeerDependencyCount { get; set; }

    public int OptionalDependencyCount { get; set; }

    public int OtherDependencyCount { get; set; }

    public int ExactVersionCount { get; set; }

    public int VersionSpecCount { get; set; }

    public int UnspecifiedVersionCount { get; set; }

    public double? DependenciesPerKLoc { get; set; }

    public List<ProjectEcosystemDependencyCount> EcosystemCounts { get; set; } = [];
}

public sealed class ProjectEcosystemDependencyCount
{
    public string Ecosystem { get; set; } = "";

    public int Count { get; set; }
}

