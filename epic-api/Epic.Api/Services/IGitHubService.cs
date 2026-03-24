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

public interface IGitHubService
{
    Task<GitHubRepoInfo> GetRepoAsync(string repo, CancellationToken ct = default);
    Task<string?> GetFileContentAsync(string repo, string path, string branch, CancellationToken ct = default);
}
