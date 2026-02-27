namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class RepositoryFileNode
{
    public string RelativePath { get; set; } = "";

    public string Extension { get; set; } = "";

    public long SizeBytes { get; set; }

    public bool IsBinary { get; set; }

    public string Sha256 { get; set; } = "";

    public int? LineCount { get; set; }

    public string? Language { get; set; } // Deterministic mapping by extension (next step)

    public string? ProjectId { get; set; } // Will link to project node later
}

