namespace Paige.Api.Engine.CfnConverter.Scan;

public sealed class RepoMetadata
{
    public string RepoName { get; set; } = null!;

    public string Branch { get; set; } = null!;

    public string CommitSha { get; set; } = null!;
}
