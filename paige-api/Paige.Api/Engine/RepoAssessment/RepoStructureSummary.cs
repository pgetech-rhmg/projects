namespace Paige.Api.Engine.RepoAssessment;

public sealed class RepoStructureSummary
{
    public required string RepoName { get; init; }

    public required string Branch { get; init; }

    public IReadOnlyCollection<string> Languages { get; init; } = [];

    public IReadOnlyCollection<string> Frameworks { get; init; } = [];

    public FileStats FileStats { get; init; } = new();

    public IReadOnlyCollection<EntryPoint> KeyFiles { get; init; } = [];
}

public sealed class FileStats
{
    public int TotalFiles { get; init; }

    public IReadOnlyDictionary<string, int> ByExtension { get; init; } = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

    public IReadOnlyDictionary<string, int> ByCategory { get; init; } = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
}

public sealed record KeyArtifact(
    string Name,
    string Pattern,
    string Category
);

public sealed record EntryPoint(
    string Name,
    string Match,
    EntryPointMatchType MatchType,
    string Category,
    int Confidence
);

public enum EntryPointMatchType
{
    FileName,
    FileExtension,
    PathContains,
    ContentContains
}

