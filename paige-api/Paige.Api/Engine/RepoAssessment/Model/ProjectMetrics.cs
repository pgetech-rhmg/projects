namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class ProjectMetrics
{
    public int TotalFiles { get; set; }

    public int TextFiles { get; set; }

    public int BinaryFiles { get; set; }

    public long TotalSizeBytes { get; set; }

    public long TotalTextSizeBytes { get; set; }

    public int TotalLinesOfCode { get; set; }

    public List<ProjectLanguageMetrics> Languages { get; set; } = [];
}

public sealed class ProjectLanguageMetrics
{
    public string Language { get; set; } = "";

    public int FileCount { get; set; }

    public int LinesOfCode { get; set; }
}

