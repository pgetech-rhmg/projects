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
    /// True when the app's Terraform project declares the remote backend EPIC
    /// manages for the config's cloud — <c>backend "s3" {}</c> for AWS/SAP,
    /// <c>backend "azurerm" {}</c> for Azure (a backend block inside a
    /// <c>terraform {}</c> block). The expected backend is cloud-specific
    /// because EPIC injects backend config per cloud at <c>terraform init</c>
    /// time. When false and the user requests an infra deploy, EPIC cannot
    /// manage the Terraform state.
    /// </summary>
    public bool HasRemoteBackend { get; set; }

    /// <summary>
    /// The Terraform backend EPIC expects for this config's cloud —
    /// <c>"s3"</c> for AWS/SAP, <c>"azurerm"</c> for Azure. Drives the UI hint
    /// so it names the backend the user must declare for their cloud.
    /// </summary>
    public string ExpectedBackend { get; set; } = "s3";

    /// <summary>
    /// True when a committed <c>*.tfstate</c> file exists in the infra folder.
    /// On init against the remote backend this triggers Terraform's interactive
    /// "copy existing state to the new backend?" prompt; the UI offers a
    /// "Force State Copy" option so EPIC can answer it non-interactively.
    /// </summary>
    public bool HasTfState { get; set; }

    /// <summary>
    /// The environment keys declared under <c>cloud.environments</c> in epic.json
    /// (e.g. ["dev","qa","uat","prod"]), or empty when the config uses no per-env
    /// map. When non-empty, the New Run modal restricts the environment dropdown
    /// to these values so a user can't select an environment the config doesn't
    /// define (which would otherwise fall back to the wrong tenant/connection).
    /// </summary>
    public IReadOnlyList<string> ConfiguredEnvironments { get; set; } = [];
}

public interface IGitHubService
{
    Task<GitHubRepoInfo> GetRepoAsync(string repo, string? source = null, CancellationToken ct = default);
    Task<string?> GetFileContentAsync(string repo, string path, string branch, string? source = null, CancellationToken ct = default);
    Task<bool> PathExistsAsync(string repo, string path, string branch, string? source = null, CancellationToken ct = default);
    Task<List<string>> FindEpicConfigsAsync(string repo, string branch, string? source = null, CancellationToken ct = default);
    Task<ConfigCheckResult> CheckInfraAsync(string repo, string branch, string configPath, string? source = null, CancellationToken ct = default);
}
