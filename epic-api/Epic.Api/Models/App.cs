namespace Epic.Api.Models;

public enum RunStatus
{
    Success,
    Failed,
    Running,
    Cancelled,
    Skipped,
    External
}

public sealed class ManagedApp
{
    public required string Name { get; set; }
    public required string Technology { get; set; }
    public string? LastPipelineRun { get; set; }
    public RunStatus? RunStatus { get; set; }
    public string? TriggeredBy { get; set; }
    public required string Cloud { get; set; }
    public required string Environment { get; set; }
}

public sealed class AppLookup
{
    public required string Name { get; set; }
    public required string DisplayName { get; set; }
    public required string Technology { get; set; }
    public required string Cloud { get; set; }
    public required string Environment { get; set; }
    public required GitHubInfo Github { get; set; }
}

public sealed class GitHubInfo
{
    public required string Repo { get; set; }
    public string? Branch { get; set; }
}

public sealed class RepoCheckResult
{
    public required string Status { get; set; } // available, in-epic-not-mine, already-mine, not-found
    public AppLookup? MasterApp { get; set; }
}

public sealed class PipelineStages
{
    public RunStatus Build { get; set; }
    public RunStatus Test { get; set; }
    public RunStatus Scan { get; set; }
    public RunStatus InfraDeploy { get; set; }
    public RunStatus AppDeploy { get; set; }
}

public sealed class PipelineRun
{
    public int Id { get; set; }
    public RunStatus Status { get; set; }
    public required string TriggeredBy { get; set; }
    public required string Branch { get; set; }
    public required string Environment { get; set; }
    public required string StartedAt { get; set; }
    public string? Duration { get; set; }
    public required PipelineStages Stages { get; set; }
}

public sealed class AwsConfig
{
    public required string AccountId { get; set; }
    public string? S3 { get; set; }
    public string? Cloudfront { get; set; }
    public string? Ec2InstanceId { get; set; }
}

public sealed class AzureConfig
{
    public required string Subscription { get; set; }
    public required string ResourceGroup { get; set; }
}

public sealed class AppDetail
{
    public required string Name { get; set; }
    public required string DisplayName { get; set; }
    public string? Description { get; set; }
    public required string AppType { get; set; }
    public required string Technology { get; set; }
    public string? NodeVersion { get; set; }
    public string? PythonVersion { get; set; }
    public string? JavaVersion { get; set; }
    public string? DotnetVersion { get; set; }
    public required string Cloud { get; set; }
    public required string Environment { get; set; }
    public required string Team { get; set; }
    public required string LastUpdatedBy { get; set; }
    public required string Domain { get; set; }
    public required GitHubInfo Github { get; set; }
    public AwsConfig? Aws { get; set; }
    public AzureConfig? Azure { get; set; }
    public required List<PipelineRun> Runs { get; set; }
}
