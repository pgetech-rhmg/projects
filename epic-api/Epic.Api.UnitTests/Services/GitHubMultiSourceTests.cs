using System.Net;
using Epic.Api.Services;
using Epic.Api.UnitTests.TestHelpers;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace Epic.Api.UnitTests.Services;

/// <summary>
/// Proves the real-world scenario: two orgs, BOTH on public github.com
/// (github.com/pgetech and github.com/PGEDigitalCatalyst), distinguished only by
/// org path segment. Both share the SAME PAT (GITHUB_TOKEN). Asserts the outbound
/// request URL host/org and the Authorization token actually sent for each source.
/// </summary>
public sealed class GitHubMultiSourceTests
{
    // Mirrors the production config: two GitHubSources on public GitHub sharing
    // one PAT (both TokenKey → GITHUB_TOKEN).
    private static IConfiguration MultiSourceConfig() => TestData.Config(
        ("GitHubSources:pgetech:ApiBase", "https://api.github.com"),
        ("GitHubSources:pgetech:Org", "pgetech"),
        ("GitHubSources:pgetech:TokenKey", "GITHUB_TOKEN"),
        ("GitHubSources:pgedc:ApiBase", "https://api.github.com"),
        ("GitHubSources:pgedc:Org", "PGEDigitalCatalyst"),
        ("GitHubSources:pgedc:TokenKey", "GITHUB_TOKEN"),
        ("GITHUB_TOKEN", "shared-tok"),
        ("GitHubDefaultSource", "pgetech"));

    [Fact]
    public void Registry_ResolvesBothOrgs_OnPublicGitHub()
    {
        var reg = new GitHubSourceRegistry(MultiSourceConfig());

        var pgetech = reg.Resolve("pgetech");
        Assert.Equal("https://api.github.com", pgetech.ApiBase);
        Assert.Equal("pgetech", pgetech.Org);

        var pgedc = reg.Resolve("pgedc");
        Assert.Equal("https://api.github.com", pgedc.ApiBase);
        Assert.Equal("PGEDigitalCatalyst", pgedc.Org);

        // Unnamed request falls back to the configured default.
        Assert.Equal("pgetech", reg.Resolve(null).Name);
    }

    [Fact]
    public async Task GetRepo_UsesOrgAndToken_PerSource()
    {
        var config = MultiSourceConfig();
        var handler = new FakeHttpMessageHandler(_ =>
            FakeHttpMessageHandler.Build(HttpStatusCode.OK,
                """{ "name": "vm-onboarding", "default_branch": "main", "private": true, "language": "TypeScript" }"""));
        var svc = new GitHubService(new HttpClient(handler), config,
            new GitHubSourceRegistry(config), TestData.Logger<GitHubService>(), TestData.NewCache());

        // Pull the SAME repo name from each org — must hit different org paths,
        // both against api.github.com, both with the shared PAT.
        await svc.GetRepoAsync("vm-onboarding", "pgedc");
        await svc.GetRepoAsync("vm-onboarding", "pgetech");

        var pgedcReq = handler.Requests[0];
        Assert.Equal("https://api.github.com/repos/PGEDigitalCatalyst/vm-onboarding", pgedcReq.RequestUri!.ToString());
        Assert.Equal("shared-tok", pgedcReq.Headers.Authorization!.Parameter);

        var pgetechReq = handler.Requests[1];
        Assert.Equal("https://api.github.com/repos/pgetech/vm-onboarding", pgetechReq.RequestUri!.ToString());
        Assert.Equal("shared-tok", pgetechReq.Headers.Authorization!.Parameter);
    }

    [Fact]
    public async Task DefaultSource_UsedWhenSourceOmitted()
    {
        var config = MultiSourceConfig();
        var handler = new FakeHttpMessageHandler(_ =>
            FakeHttpMessageHandler.Build(HttpStatusCode.OK,
                """{ "name": "epic-web", "default_branch": "main", "private": false, "language": "TypeScript" }"""));
        var svc = new GitHubService(new HttpClient(handler), config,
            new GitHubSourceRegistry(config), TestData.Logger<GitHubService>(), TestData.NewCache());

        await svc.GetRepoAsync("epic-web"); // no source → default (pgetech)

        Assert.Equal("https://api.github.com/repos/pgetech/epic-web", handler.Requests[0].RequestUri!.ToString());
        Assert.Equal("shared-tok", handler.Requests[0].Headers.Authorization!.Parameter);
    }

    [Fact]
    public void UnknownSource_Throws()
    {
        var reg = new GitHubSourceRegistry(MultiSourceConfig());
        Assert.Throws<InvalidOperationException>(() => reg.Resolve("nonexistent"));
    }

    [Fact]
    public void LiteralDefault_AliasesConfiguredDefault_ForMigratedApps()
    {
        // Apps onboarded before multi-org support were backfilled to
        // GithubSource="default" by the migration. With named sources configured
        // there is no literal "default" entry, so it must alias the configured
        // default (pgetech) rather than throw — otherwise every legacy app breaks.
        var reg = new GitHubSourceRegistry(MultiSourceConfig());
        Assert.Equal("pgetech", reg.Resolve("default").Name);
    }
}
