namespace Paige.Api.Engine.CfnConverter.Scan;

public sealed class RepoScanRequest
{
    public string RepoName { get; set; } = null!;

    public string Branch { get; set; } = "main";
}
