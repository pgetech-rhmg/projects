namespace Epic.Api.Models;

public enum RunStatus
{
    Success,
    Failed,
    Running,
    Canceled,
    Skipped,
    External,
    Pending
}

public sealed class ManagedApp
{
    public required string Name { get; set; }
    public string? AppName { get; set; }
    public required string Technology { get; set; }
    // GitHub org the app's repo lives in (resolved from the app's source), e.g.
    // "pgetech" or "PGEDigitalCatalyst".
    public string? GithubOrg { get; set; }
    public string? LastPipelineRun { get; set; }
    public string? Branch { get; set; }
    public int? RunId { get; set; }
    public RunStatus? RunStatus { get; set; }
    public string? TriggeredBy { get; set; }
    public required string Cloud { get; set; }
    public required string Environment { get; set; }
    public double? SuccessRate { get; set; }
    public string? AvgDuration { get; set; }
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
    public RunStatus Prepare { get; set; }
    public RunStatus Download { get; set; }
    public RunStatus Review { get; set; }
    public RunStatus Build { get; set; }
    public RunStatus Test { get; set; }
    public RunStatus Scan { get; set; }
    public RunStatus InfraDeploy { get; set; }
    public RunStatus AppDeploy { get; set; }
    public RunStatus IntegrationTest { get; set; }
}

public sealed class StageStep
{
    public required string Name { get; set; }
    public RunStatus Status { get; set; }
    public string? Duration { get; set; }
    public int? LogId { get; set; }
}

public sealed class StageJob
{
    public required string Name { get; set; }
    public RunStatus Status { get; set; }
    public string? Duration { get; set; }
    public required List<StageStep> Steps { get; set; }
}

public sealed class StageDetail
{
    public required string StageName { get; set; }
    public RunStatus Status { get; set; }
    public string? Duration { get; set; }
    public required List<StageJob> Jobs { get; set; }
}

// Summary view of the compliance-report.json the Review stage produces —
// the tool version plus the verdict distribution the dashboard renders above
// the Download Report button.
public sealed class ComplianceSummary
{
    public string? Tool { get; set; }
    public string? Version { get; set; }
    public string? SpecSource { get; set; }
    public string? ScannedAt { get; set; }
    public int Total { get; set; }
    public required Dictionary<string, int> ByVerdict { get; set; }
}

// Full parsed compliance-report.json — the summary plus the app profile and the
// per-control findings, so the dashboard can render the report natively (grouped
// findings, verdict pills) instead of re-parsing Markdown.
public sealed class ComplianceReport
{
    public required ComplianceSummary Summary { get; set; }
    public ComplianceProfile? Profile { get; set; }
    public required List<ComplianceFinding> Findings { get; set; }
}

public sealed class ComplianceProfile
{
    public List<string>? Kinds { get; set; }
    public string? AuthModel { get; set; }
    public string? Idp { get; set; }
    public string? Narrative { get; set; }
}

public sealed class ComplianceFinding
{
    public required string NistId { get; set; }
    public string? Title { get; set; }
    public string? Requirement { get; set; }
    public required string Verdict { get; set; }
    public string? Kind { get; set; }
    public string? Severity { get; set; }
    public string? Message { get; set; }
    public string? Remediation { get; set; }
    public string? InheritedFrom { get; set; }
    public List<string>? Evidence { get; set; }
}

public sealed class PipelineRun
{
    public int Id { get; set; }
    public int? OrchestratorId { get; set; }
    public RunStatus Status { get; set; }
    public required string TriggeredBy { get; set; }
    public required string Branch { get; set; }
    public required string Cloud { get; set; }
    public required string Environment { get; set; }
    public string? AppName { get; set; }
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
    public bool HasInfra { get; set; }
    public AwsConfig? Aws { get; set; }
    public AzureConfig? Azure { get; set; }
    public double? SuccessRate { get; set; }
    public string? AvgDuration { get; set; }
}

public sealed class PipelineRunPage
{
    public int Total { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public required List<PipelineRun> Runs { get; set; }
}
