namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class ProjectStructuralSignals
{
    public bool IsLegacyDotNetFramework { get; set; }

    public bool IsModernDotNet { get; set; }

    public bool UsesVersionSpecs { get; set; }

    public bool HasNoDependencies { get; set; }

    public bool HighDependencyDensity { get; set; }

    public bool LargeProject { get; set; }

    public bool MixedLanguageProject { get; set; }
}

public sealed class RepositoryStructuralSignals
{
    public bool IsPolyglotRepository { get; set; }

    public int DistinctProjectTypes { get; set; }

    public int DistinctLanguages { get; set; }
}

