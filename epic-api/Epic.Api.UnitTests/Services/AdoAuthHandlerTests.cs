using System.Net;
using Azure.Core;
using Epic.Api.Services;
using Epic.Api.UnitTests.TestHelpers;
using Xunit;

namespace Epic.Api.UnitTests.Services;

/// <summary>
/// Verifies AdoAuthHandler applies the Entra service-principal bearer token to
/// every outbound request (replacing the old per-method PAT Basic-auth header).
/// </summary>
public sealed class AdoAuthHandlerTests
{
    private sealed class StubTokenCredential(string token) : TokenCredential
    {
        public override AccessToken GetToken(TokenRequestContext requestContext, CancellationToken cancellationToken)
            => new(token, DateTimeOffset.UtcNow.AddHours(1));

        public override ValueTask<AccessToken> GetTokenAsync(TokenRequestContext requestContext, CancellationToken cancellationToken)
            => new(GetToken(requestContext, cancellationToken));
    }

    [Fact]
    public async Task SetsBearerAuthorizationHeader_OnEveryRequest()
    {
        var inner = FakeHttpMessageHandler.Fixed(HttpStatusCode.OK, "{}");
        var handler = new AdoAuthHandler(new StubTokenCredential("tok-123")) { InnerHandler = inner };
        using var client = new HttpClient(handler);

        await client.GetAsync("https://dev.azure.com/pgetech/EPIC-Pipeline/_apis/pipelines?api-version=7.1");

        var sent = Assert.Single(inner.Requests);
        Assert.NotNull(sent.Headers.Authorization);
        Assert.Equal("Bearer", sent.Headers.Authorization!.Scheme);
        Assert.Equal("tok-123", sent.Headers.Authorization.Parameter);
    }
}
