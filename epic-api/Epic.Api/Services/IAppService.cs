using Epic.Api.Models;

namespace Epic.Api.Services;

public interface IAppService
{
    Task<List<ManagedApp>> GetUserAppsAsync(CancellationToken ct = default);
    Task<AppDetail?> GetAppAsync(string name, CancellationToken ct = default);
    Task<PipelineRunPage?> GetRunsPageAsync(string name, int page, int pageSize, CancellationToken ct = default);
    Task<RepoCheckResult> CheckRepoAsync(string repo, CancellationToken ct = default);
    Task<ManagedApp> AddToMyAppsAsync(string name, CancellationToken ct = default);
    Task<AppDetail> OnboardAppAsync(string repo, CancellationToken ct = default);
    Task<TriggerRunResponse> TriggerRunAsync(string appName, string branch, string environment, string config, bool build, bool tests, bool scan, bool deploy, bool integrations, string deployInfra, CancellationToken ct = default);
    Task RemoveFromMyAppsAsync(string name, CancellationToken ct = default);
    Task CancelRunAsync(string appName, int runId, CancellationToken ct = default);
    Task<StageDetail?> GetStageDetailAsync(string appName, int runId, string stageName, CancellationToken ct = default);
    Task<string?> GetStepLogAsync(string appName, int runId, int logId, CancellationToken ct = default);
    Task<List<string>> FindConfigsAsync(string repo, string branch, CancellationToken ct = default);
    Task<ConfigCheckResult> CheckConfigInfraAsync(string repo, string branch, string configPath, CancellationToken ct = default);
}
