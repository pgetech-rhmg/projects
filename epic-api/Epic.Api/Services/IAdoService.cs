using Epic.Api.Models;

namespace Epic.Api.Services;

public sealed class AdoPipelineRun
{
    public int Id { get; set; }
    public required string Status { get; set; }
    public required string TriggeredBy { get; set; }
    public required string Branch { get; set; }
    public required string Environment { get; set; }
    public DateTime StartedAt { get; set; }
    public string? Duration { get; set; }
    public required PipelineStages Stages { get; set; }
}

public interface IAdoService
{
    Task<List<AdoPipelineRun>> GetRunsForAppAsync(string appName, int top = 20, CancellationToken ct = default);
}
