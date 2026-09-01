using Epic.Api.Services;

namespace Epic.Api.UnitTests.TestHelpers;

/// <summary>
/// Test double for <see cref="IGitHubAppTokenProvider"/>. Returns a fixed token and
/// counts calls. PAT-path tests (sources with no InstallationId) never invoke it;
/// App-path tests assert the returned token is what GitHubService sends.
/// </summary>
public sealed class StubGitHubAppTokenProvider(string token = "inst-token") : IGitHubAppTokenProvider
{
    public int Calls { get; private set; }

    public Task<string> GetInstallationTokenAsync(GitHubSource source, CancellationToken ct)
    {
        Calls++;
        return Task.FromResult(token);
    }
}
