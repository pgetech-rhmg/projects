namespace Paige.Api.Engine.Common;

public sealed class ClonedRepo
{
    public string LocalPath { get; set; } = null!;

    public string CommitSha { get; set; } = null!;
}
