namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class RepositoryMetrics
{
    public int TotalFiles { get; set; }

    public int TextFiles { get; set; }

    public int BinaryFiles { get; set; }

    public long TotalSizeBytes { get; set; }

    public long TotalTextSizeBytes { get; set; }

    public int TotalLinesOfCode { get; set; }
}

