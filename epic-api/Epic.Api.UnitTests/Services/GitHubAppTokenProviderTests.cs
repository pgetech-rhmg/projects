using System.Net;
using System.Security.Cryptography;
using Epic.Api.Services;
using Epic.Api.UnitTests.TestHelpers;
using Xunit;

namespace Epic.Api.UnitTests.Services;

/// <summary>
/// Covers GitHubAppTokenProvider: RS256 app-JWT minting over a real (test) PEM,
/// the installation-token exchange, and per-installation caching.
/// </summary>
public sealed class GitHubAppTokenProviderTests
{
    private static string TestPem()
    {
        using var rsa = RSA.Create(2048);
        return rsa.ExportPkcs8PrivateKeyPem();
    }

    private static GitHubSource AppSource(long installationId = 158059996L) =>
        new("pgetech", "https://api.github.com", "pgetech", TokenKey: null, InstallationId: installationId);

    private static GitHubAppTokenProvider Make(HttpMessageHandler handler, string pem)
    {
        var config = TestData.Config(("GITHUB_APP_ID", "12345"), ("GITHUB_APP_PRIVATE_KEY", pem));
        return new GitHubAppTokenProvider(new HttpClient(handler), config, TestData.NewCache(), TestData.Logger<GitHubAppTokenProvider>());
    }

    [Fact]
    public async Task MintsBearerJwt_ExchangesForInstallationToken()
    {
        var handler = new FakeHttpMessageHandler(_ =>
            FakeHttpMessageHandler.Build(HttpStatusCode.Created,
                $$"""{ "token": "ghs_installtoken", "expires_at": "{{DateTimeOffset.UtcNow.AddHours(1):o}}" }"""));
        var provider = Make(handler, TestPem());

        var token = await provider.GetInstallationTokenAsync(AppSource(), CancellationToken.None);

        Assert.Equal("ghs_installtoken", token);

        // The exchange POST hit the installation endpoint with a Bearer app-JWT
        // (three dot-separated base64url segments).
        var req = Assert.Single(handler.Requests);
        Assert.Equal(HttpMethod.Post, req.Method);
        Assert.Equal("https://api.github.com/app/installations/158059996/access_tokens", req.RequestUri!.ToString());
        Assert.Equal("Bearer", req.Headers.Authorization!.Scheme);
        Assert.Equal(3, req.Headers.Authorization!.Parameter!.Split('.').Length);
    }

    [Fact]
    public async Task CachesToken_SecondCallDoesNotReExchange()
    {
        var calls = 0;
        var handler = new FakeHttpMessageHandler(_ =>
        {
            calls++;
            return FakeHttpMessageHandler.Build(HttpStatusCode.Created,
                $$"""{ "token": "ghs_cached", "expires_at": "{{DateTimeOffset.UtcNow.AddHours(1):o}}" }""");
        });
        var provider = Make(handler, TestPem());

        await provider.GetInstallationTokenAsync(AppSource(), CancellationToken.None);
        var second = await provider.GetInstallationTokenAsync(AppSource(), CancellationToken.None);

        Assert.Equal("ghs_cached", second);
        Assert.Equal(1, calls); // cached — no second POST
    }

    [Fact]
    public async Task ExchangeFailure_Throws()
    {
        var handler = FakeHttpMessageHandler.Fixed(HttpStatusCode.NotFound, """{ "message": "Not Found" }""");
        var provider = Make(handler, TestPem());

        await Assert.ThrowsAsync<InvalidOperationException>(
            () => provider.GetInstallationTokenAsync(AppSource(), CancellationToken.None));
    }

    [Fact]
    public async Task MissingInstallationId_Throws()
    {
        var provider = Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.OK, "{}"), TestPem());
        var patSource = new GitHubSource("pgedc", "https://api.github.com", "PGEDigitalCatalyst", "GITHUB_TOKEN", InstallationId: null);

        await Assert.ThrowsAsync<InvalidOperationException>(
            () => provider.GetInstallationTokenAsync(patSource, CancellationToken.None));
    }
}
