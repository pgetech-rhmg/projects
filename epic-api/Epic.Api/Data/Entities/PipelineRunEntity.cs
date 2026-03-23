namespace Epic.Api.Data.Entities;

public sealed class PipelineRunEntity
{
    public int Id { get; set; }
    public int AppId { get; set; }
    public required string Status { get; set; }
    public required string TriggeredBy { get; set; }
    public required string Branch { get; set; }
    public required string Environment { get; set; }
    public DateTime StartedAt { get; set; } = DateTime.UtcNow;
    public string? Duration { get; set; }

    // Stage statuses
    public string StageBuild { get; set; } = "Skipped";
    public string StageTest { get; set; } = "Skipped";
    public string StageScan { get; set; } = "Skipped";
    public string StageInfraDeploy { get; set; } = "Skipped";
    public string StageAppDeploy { get; set; } = "Skipped";

    // Navigation
    public AppEntity App { get; set; } = null!;
}
