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
    public string? BuildTestTool { get; set; }
    public string? ScanTool { get; set; }
    public string? IntegrationTestTool { get; set; }

    /// <summary>
    /// True when the app's Terraform project declares an S3 remote backend
    /// (a <c>backend "s3" {}</c> block inside a <c>terraform {}</c> block).
    /// When false and the user requests an infra deploy, EPIC cannot manage
    /// the Terraform state.
    /// </summary>
    public bool HasS3Backend { get; set; }

    /// <summary>
    /// True when a committed <c>*.tfstate</c> file exists in the infra folder.
    /// On init against the S3 backend this triggers Terraform's interactive
    /// "copy existing state to the new backend?" prompt; the UI offers a
    /// "Force State Copy" option so EPIC can answer it non-interactively.
    /// </summary>
    public bool HasTfState { get; set; }
}

public interface IGitHubService
{
    Task<GitHubRepoInfo> GetRepoAsync(string repo, string? source = null, CancellationToken ct = default);
    Task<string?> GetFileContentAsync(string repo, string path, string branch, string? source = null, CancellationToken ct = default);
    Task<bool> PathExistsAsync(string repo, string path, string branch, string? source = null, CancellationToken ct = default);
    Task<List<string>> FindEpicConfigsAsync(string repo, string branch, string? source = null, CancellationToken ct = default);
    Task<ConfigCheckResult> CheckInfraAsync(string repo, string branch, string configPath, string? source = null, CancellationToken ct = default);
}
