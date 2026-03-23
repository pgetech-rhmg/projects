namespace Epic.Api.Services;

public interface IGitHubService
{
    Task<bool> RepoExistsAsync(string repo, CancellationToken ct = default);
}
