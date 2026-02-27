namespace Paige.Api.Engine.Common;

public interface IRepoCloner
{
    Task<ClonedRepo> CloneAsync(string repoUrl, string branch, string githubToken, CancellationToken cancellationToken);
}
