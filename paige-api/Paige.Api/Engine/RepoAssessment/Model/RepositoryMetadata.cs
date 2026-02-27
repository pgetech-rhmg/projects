namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class RepositoryMetadata
{
    public string RootPath { get; set; } = "";

    public string RepositoryName { get; set; } = "";

    public DateTimeOffset AssessedAtUtc { get; set; }

    public string RepositoryHash { get; set; } = ""; // Deterministic hash of file hashes
}

