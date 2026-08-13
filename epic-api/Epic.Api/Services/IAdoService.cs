using Epic.Api.Models;

namespace Epic.Api.Services;

/// <summary>
/// Thrown when an Azure DevOps REST call returns a non-success status. Distinct
/// type so the exception middleware maps it to 502 Bad Gateway (an upstream
/// failure) rather than 500 (which wrongly implies epic-api itself is broken).
/// Carries the upstream status so the response body can report it.
/// </summary>
public sealed class AdoUpstreamException(int upstreamStatus, string body)
    : Exception($"ADO API returned {upstreamStatus}: {body}")
{
    public int UpstreamStatus { get; } = upstreamStatus;
}

public sealed class AdoPipelineRun
{
    public int Id { get; set; }
    public int? OrchestratorId { get; set; }
    public required string Status { get; set; }
    public required string TriggeredBy { get; set; }
    public required string Branch { get; set; }
    public required string Environment { get; set; }
    public string? Cloud { get; set; }
    public string? AppName { get; set; }
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
    public string? Cloud { get; set; }
    public string? AppType { get; set; }
    public string? AppName { get; set; }
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
    Task<List<AdoPipelineRun>> GetRunsForAppAsync(string repo, int? afterBuildId = null, int top = 20, CancellationToken ct = default);
    Task<List<AdoLatestRun>> GetRecentRunsForAppAsync(string repo, int top = 20, CancellationToken ct = default);
    Task<(int Total, int Successful, TimeSpan TotalDuration)> GetCompletedRunCountsAsync(string repo, CancellationToken ct = default);
    Task<int> GetTotalRunCountAsync(string repo, CancellationToken ct = default);
    Task<AdoRunsPage> GetRunsPageAsync(string repo, int page, int pageSize, CancellationToken ct = default);
    Task<AdoTriggerResult> TriggerOrchestratorAsync(string repo, string branch, string environment, string config, bool review, bool build, bool tests, bool scan, bool deploy, bool integrations, string deployInfra, bool forceStateCopy, string triggeredBy, string owner, string githubHost, CancellationToken ct = default);
    Task CancelBuildAsync(int buildId, CancellationToken ct = default);
    Task<StageDetail?> GetStageDetailAsync(int buildId, string stageName, CancellationToken ct = default);
    Task<string?> GetStepLogAsync(int buildId, int logId, CancellationToken ct = default);
    Task<string?> GetScanResultUrlAsync(int buildId, CancellationToken ct = default);
    Task<string?> GetComplianceReportAsync(int buildId, CancellationToken ct = default);
    Task<ComplianceSummary?> GetComplianceSummaryAsync(int buildId, CancellationToken ct = default);
    Task<ComplianceReport?> GetComplianceReportJsonAsync(int buildId, CancellationToken ct = default);
}
