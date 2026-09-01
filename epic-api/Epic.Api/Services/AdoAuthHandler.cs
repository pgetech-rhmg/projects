using System.Net.Http.Headers;
using Azure.Core;

namespace Epic.Api.Services;

/// <summary>
/// Applies Azure DevOps REST auth to every outbound request on the AdoService
/// typed HttpClient. Replaces the old per-method PAT Basic-auth header with an
/// Entra ID service-principal bearer token (client-credentials flow).
///
/// The <see cref="TokenCredential"/> (a ClientSecretCredential, registered in
/// Program.cs) caches and auto-refreshes the ~1h token internally, so acquiring
/// one per request is cheap — only near-expiry acquisitions hit the network.
///
/// Registered AFTER the retry resilience handler, so it sits innermost (closest
/// to the network) and every retry re-applies a fresh (possibly refreshed) token.
/// </summary>
public sealed class AdoAuthHandler(TokenCredential credential) : DelegatingHandler
{
    // Well-known Azure DevOps resource (application) ID. ".default" requests the
    // app's statically-configured permissions under the client-credentials flow.
    private static readonly string[] Scopes = ["499b84ac-1321-427f-aa17-267ca6975798/.default"];

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var token = await credential.GetTokenAsync(new TokenRequestContext(Scopes), cancellationToken);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token.Token);
        return await base.SendAsync(request, cancellationToken);
    }
}
