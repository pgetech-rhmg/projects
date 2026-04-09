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

public sealed class AdoLatestRun
{
    public int Id { get; set; }
    public required string Status { get; set; }
    public required string TriggeredBy { get; set; }
    public required string Branch { get; set; }
    public required string Environment { get; set; }
    public DateTime StartedAt { get; set; }
    public string? Duration { get; set; }
}

public sealed class AdoTriggerResult
{
    public int RunId { get; set; }
    public required string Url { get; set; }
}

public sealed class AdoRunsPage
{
    public int Total { get; set; }
    public required List<AdoPipelineRun> Runs { get; set; }
}

public interface IAdoService
{
    Task<List<AdoPipelineRun>> GetRunsForAppAsync(string appName, int? afterBuildId = null, int top = 20, CancellationToken ct = default);
    Task<List<AdoLatestRun>> GetRecentRunsForAppAsync(string appName, int top = 20, CancellationToken ct = default);
    Task<(int Total, int Successful)> GetCompletedRunCountsAsync(string appName, CancellationToken ct = default);
    Task<int> GetTotalRunCountAsync(string appName, CancellationToken ct = default);
    Task<AdoRunsPage> GetRunsPageAsync(string appName, int page, int pageSize, CancellationToken ct = default);
    Task<AdoTriggerResult> TriggerOrchestratorAsync(string repo, string branch, string environment, bool build, bool tests, bool scan, bool deploy, bool integrations, string deployInfra, CancellationToken ct = default);
    Task CancelBuildAsync(int buildId, CancellationToken ct = default);
}
