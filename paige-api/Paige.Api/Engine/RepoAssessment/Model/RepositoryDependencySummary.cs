namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class RepositoryDependencySummary
{
    public int TotalProjects { get; set; }

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

    public List<RepositoryEcosystemDependencyCount> EcosystemCounts { get; set; } = [];

    public List<RepositoryProjectDependencyRanking> TopProjectsByDependencyCount { get; set; } = [];
}

public sealed class RepositoryEcosystemDependencyCount
{
    public string Ecosystem { get; set; } = "";

    public int Count { get; set; }
}

public sealed class RepositoryProjectDependencyRanking
{
    public string ProjectId { get; set; } = "";

    public string ProjectName { get; set; } = "";

    public int DependencyCount { get; set; }
}

