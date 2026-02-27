namespace Paige.Api.Engine.CfnConverter.Scan;

public sealed class RepoScanResult
{
    public RepoMetadata Repo { get; set; } = null!;

    public IReadOnlyList<CloudFormationScanResult> CloudFormationFiles { get; set; } = Array.Empty<CloudFormationScanResult>();

    public RepoScanSummary Summary { get; set; } = null!;
}
