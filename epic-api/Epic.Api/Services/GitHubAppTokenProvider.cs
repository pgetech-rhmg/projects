using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Caching.Memory;

namespace Epic.Api.Services;

public interface IGitHubAppTokenProvider
{
    /// <summary>
    /// Returns a valid GitHub App *installation* access token for the source's
    /// installation, minting a fresh one (and caching it) when none is cached.
    /// </summary>
    Task<string> GetInstallationTokenAsync(GitHubSource source, CancellationToken ct);
}

/// <summary>
/// Mints short-lived GitHub App installation tokens, replacing the shared PAT for
/// sources that carry an <see cref="GitHubSource.InstallationId"/>. Flow: sign a
/// ~10-min app JWT (RS256) with the App private key → exchange it at
/// <c>POST {apiBase}/app/installations/{id}/access_tokens</c> for a ~1h installation
/// token → cache per-installation (~55m). Zero external deps: RS256 signing uses
/// <see cref="RSA.ImportFromPem"/> (handles both PKCS#1 "RSA PRIVATE KEY" and PKCS#8).
/// </summary>
public sealed class GitHubAppTokenProvider(
    HttpClient httpClient,
    IConfiguration configuration,
    IMemoryCache cache,
    ILogger<GitHubAppTokenProvider> logger) : IGitHubAppTokenProvider
{
    private const string AppIdKey = "GITHUB_APP_ID";
    private const string PrivateKeyKey = "GITHUB_APP_PRIVATE_KEY";

    public async Task<string> GetInstallationTokenAsync(GitHubSource source, CancellationToken ct)
    {
        if (source.InstallationId is not long installationId)
            throw new InvalidOperationException(
                $"GitHub source '{source.Name}' has no InstallationId — cannot mint a GitHub App token.");

        var cacheKey = $"gh-inst-token:{installationId}";
        if (cache.TryGetValue<string>(cacheKey, out var cached) && cached is not null)
            return cached;

        var appJwt = CreateAppJwt();

        var url = $"{source.ApiBase}/app/installations/{installationId}/access_tokens";
        using var request = new HttpRequestMessage(HttpMethod.Post, url);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", appJwt);
        request.Headers.UserAgent.Add(new ProductInfoHeaderValue("EPIC-API", "1.0"));
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github+json"));

        var response = await httpClient.SendAsync(request, ct);
        if (!response.IsSuccessStatusCode)
        {
            var detail = await response.Content.ReadAsStringAsync(ct);
            logger.LogError(
                "GitHub App token exchange failed for installation {InstallationId}: {StatusCode} {Detail}",
                installationId, (int)response.StatusCode, detail);
            throw new InvalidOperationException(
                $"GitHub App installation token exchange returned {(int)response.StatusCode} for installation {installationId}.");
        }

        var body = await response.Content.ReadAsStringAsync(ct);
        using var doc = JsonDocument.Parse(body);
        var root = doc.RootElement;
        var token = root.GetProperty("token").GetString()
            ?? throw new InvalidOperationException("GitHub App installation token response had no 'token'.");
        var expiresAt = root.TryGetProperty("expires_at", out var exp) && exp.ValueKind == JsonValueKind.String
            ? exp.GetDateTimeOffset()
            : DateTimeOffset.UtcNow.AddMinutes(60);

        // Cache until ~5 min before expiry so we never hand out a token about to die.
        var ttl = expiresAt - DateTimeOffset.UtcNow - TimeSpan.FromMinutes(5);
        if (ttl > TimeSpan.Zero)
            cache.Set(cacheKey, token, new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = ttl,
                Size = 1,
            });

        return token;
    }

    // Builds a signed RS256 JWT identifying the GitHub App (iss = App ID), valid for
    // ~10 min. iat is backdated 60s per GitHub's guidance to tolerate clock skew.
    private string CreateAppJwt()
    {
        var appId = configuration[AppIdKey]
            ?? throw new InvalidOperationException($"{AppIdKey} not configured.");
        // A PEM stored as a JSON/env string may carry literal "\n" instead of real
        // newlines; normalize so ImportFromPem can parse it either way.
        var pem = (configuration[PrivateKeyKey]
            ?? throw new InvalidOperationException($"{PrivateKeyKey} not configured."))
            .Replace("\\n", "\n");

        var now = DateTimeOffset.UtcNow;
        var header = new { alg = "RS256", typ = "JWT" };
        var payload = new
        {
            iat = now.AddSeconds(-60).ToUnixTimeSeconds(),
            exp = now.AddMinutes(9).ToUnixTimeSeconds(),
            iss = appId,
        };

        var signingInput = $"{Base64UrlJson(header)}.{Base64UrlJson(payload)}";

        using var rsa = RSA.Create();
        rsa.ImportFromPem(pem);
        var signature = rsa.SignData(
            Encoding.ASCII.GetBytes(signingInput), HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);

        return $"{signingInput}.{Base64UrlEncode(signature)}";
    }

    private static string Base64UrlJson(object value) =>
        Base64UrlEncode(JsonSerializer.SerializeToUtf8Bytes(value));

    private static string Base64UrlEncode(byte[] bytes) =>
        Convert.ToBase64String(bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_');
}
