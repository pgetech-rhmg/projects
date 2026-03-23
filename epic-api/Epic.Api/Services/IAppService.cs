using Epic.Api.Models;

namespace Epic.Api.Services;

public interface IAppService
{
    Task<List<ManagedApp>> GetUserAppsAsync(CancellationToken ct = default);
    Task<AppDetail?> GetAppAsync(string name, CancellationToken ct = default);
    Task<RepoCheckResult> CheckRepoAsync(string repo, CancellationToken ct = default);
    Task<ManagedApp> AddToMyAppsAsync(string name, CancellationToken ct = default);
    Task<AppDetail> OnboardAppAsync(string repo, string branch, CancellationToken ct = default);
    Task<PipelineRun> TriggerRunAsync(string appName, string branch, string environment, CancellationToken ct = default);
}
