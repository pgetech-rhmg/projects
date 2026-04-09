using Epic.Api.Models;

namespace Epic.Api.Services;

public interface IAppService
{
    Task<List<ManagedApp>> GetUserAppsAsync(CancellationToken ct = default);
    Task<AppDetail?> GetAppAsync(string name, CancellationToken ct = default);
    Task<PipelineRunPage?> GetRunsPageAsync(string name, int page, int pageSize, CancellationToken ct = default);
    Task<RepoCheckResult> CheckRepoAsync(string repo, CancellationToken ct = default);
    Task<ManagedApp> AddToMyAppsAsync(string name, CancellationToken ct = default);
    Task<AppDetail> OnboardAppAsync(string repo, string branch, CancellationToken ct = default);
    Task<TriggerRunResponse> TriggerRunAsync(string appName, string branch, string environment, bool build, bool tests, bool scan, bool deploy, bool integrations, string deployInfra, CancellationToken ct = default);
    Task RemoveFromMyAppsAsync(string name, CancellationToken ct = default);
    Task CancelRunAsync(string appName, int runId, CancellationToken ct = default);
}
