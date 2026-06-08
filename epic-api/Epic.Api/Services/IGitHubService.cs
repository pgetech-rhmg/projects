namespace Epic.Api.Services;

public sealed class GitHubRepoInfo
{
    public bool Exists { get; set; }
    public string? Name { get; set; }
    public string? Description { get; set; }
    public string? Language { get; set; }
    public string? DefaultBranch { get; set; }
    public bool IsPrivate { get; set; }
}

public sealed class ConfigCheckResult
{
    public bool HasInfra { get; set; }
    public bool HasInfraParams { get; set; }
    public string? AppType { get; set; }
}

public interface IGitHubService
{
    Task<GitHubRepoInfo> GetRepoAsync(string repo, CancellationToken ct = default);
    Task<string?> GetFileContentAsync(string repo, string path, string branch, CancellationToken ct = default);
    Task<bool> PathExistsAsync(string repo, string path, string branch, CancellationToken ct = default);
    Task<List<string>> FindEpicConfigsAsync(string repo, string branch, CancellationToken ct = default);
    Task<ConfigCheckResult> CheckInfraAsync(string repo, string branch, string configPath, CancellationToken ct = default);
}
