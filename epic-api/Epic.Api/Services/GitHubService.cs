using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;

namespace Epic.Api.Services;

public sealed class GitHubService(HttpClient httpClient, IConfiguration configuration, ILogger<GitHubService> logger) : IGitHubService
{
    private string OrgName => new Uri(
        configuration["GITHUB_BASE_URL"]
        ?? throw new InvalidOperationException("GITHUB_BASE_URL not configured.")
    ).AbsolutePath.Trim('/');

    private string Token =>
        configuration["GITHUB_TOKEN"]
        ?? throw new InvalidOperationException("GITHUB_TOKEN not configured.");

    public async Task<GitHubRepoInfo> GetRepoAsync(string repo, CancellationToken ct = default)
    {
        var repoJson = await CallApiAsync($"https://api.github.com/repos/{OrgName}/{repo}", ct);

        if (repoJson is null)
            return new GitHubRepoInfo { Exists = false };

        var repo_ = repoJson.Value;

        var language = repo_.TryGetProperty("language", out var langProp) && langProp.ValueKind != JsonValueKind.Null
            ? langProp.GetString()
            : null;

        // If no primary language, try the languages endpoint for more detail
        if (string.IsNullOrEmpty(language))
        {
            var languagesJson = await CallApiAsync($"https://api.github.com/repos/{OrgName}/{repo}/languages", ct);
            if (languagesJson is not null)
            {
                // Languages come as { "TypeScript": 45000, "SCSS": 8000, "HTML": 3000 }
                // Pick the one with the most bytes
                string? topLang = null;
                long topBytes = 0;
                foreach (var prop in languagesJson.Value.EnumerateObject())
                {
                    var bytes = prop.Value.GetInt64();
                    if (bytes > topBytes)
                    {
                        topLang = prop.Name;
                        topBytes = bytes;
                    }
                }
                language = topLang;
            }
        }

        return new GitHubRepoInfo
        {
            Exists = true,
            Name = repo_.GetProperty("name").GetString(),
            Description = repo_.TryGetProperty("description", out var descProp) && descProp.ValueKind != JsonValueKind.Null
                ? descProp.GetString()
                : null,
            Language = language,
            DefaultBranch = repo_.GetProperty("default_branch").GetString(),
            IsPrivate = repo_.GetProperty("private").GetBoolean()
        };
    }

    public async Task<bool> PathExistsAsync(string repo, string path, string branch, CancellationToken ct = default)
    {
        var url = $"https://api.github.com/repos/{OrgName}/{repo}/contents/{path}?ref={Uri.EscapeDataString(branch)}";
        var json = await CallApiAsync(url, ct);
        return json is not null;
    }

    public async Task<string?> GetFileContentAsync(string repo, string path, string branch, CancellationToken ct = default)
    {
        var url = $"https://api.github.com/repos/{OrgName}/{repo}/contents/{path}?ref={Uri.EscapeDataString(branch)}";
        var json = await CallApiAsync(url, ct);
        if (json is null) return null;

        var encoding = json.Value.TryGetProperty("encoding", out var enc) ? enc.GetString() : null;
        var content = json.Value.TryGetProperty("content", out var c) ? c.GetString() : null;

        if (encoding == "base64" && content is not null)
            return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(content));

        return content;
    }

    public async Task<List<string>> FindEpicConfigsAsync(string repo, string branch, CancellationToken ct = default)
    {
        var url = $"https://api.github.com/repos/{OrgName}/{repo}/git/trees/{Uri.EscapeDataString(branch)}?recursive=1";
        var json = await CallApiAsync(url, ct);
        if (json is null) return [];

        var results = new List<string>();
        if (json.Value.TryGetProperty("tree", out var tree))
        {
            foreach (var item in tree.EnumerateArray())
            {
                var type = item.TryGetProperty("type", out var t) ? t.GetString() : null;
                var path = item.TryGetProperty("path", out var p) ? p.GetString() : null;
                if (type == "blob" && path is not null &&
                    (path.EndsWith("/epic.json") || path == "epic.json"))
                {
                    results.Add(path);
                }
            }
        }

        return results;
    }

    public async Task<ConfigCheckResult> CheckInfraAsync(string repo, string branch, string configPath, CancellationToken ct = default)
    {
        var infraPath = ".infra";
        string? appType = null;
        var hasInfraParams = false;
        try
        {
            var content = await GetFileContentAsync(repo, configPath, branch, ct);
            if (content is not null)
            {
                var doc = System.Text.Json.JsonDocument.Parse(content).RootElement;
                if (doc.TryGetProperty("app", out var app))
                {
                    if (app.TryGetProperty("infraPath", out var ip))
                        infraPath = ip.GetString() ?? ".infra";
                    if (app.TryGetProperty("appType", out var at))
                        appType = at.GetString();
                }
                else if (doc.TryGetProperty("infraPath", out var ipRoot))
                    infraPath = ipRoot.GetString() ?? ".infra";

                if (doc.TryGetProperty("cloud", out var cloud))
                    hasInfraParams = HasInfraParamsForAppType(cloud, appType);
            }
        }
        catch (Exception ex)
        {
            logger.LogDebug(ex, "Failed to parse epic.json for {Repo}@{Branch} — using defaults", repo, branch);
        }

        var resolved = infraPath.TrimStart('/');
        var hasInfra = await PathExistsAsync(repo, resolved, branch, ct);
        return new ConfigCheckResult { HasInfra = hasInfra, HasInfraParams = hasInfraParams, AppType = appType };
    }

    private static bool HasInfraParamsForAppType(System.Text.Json.JsonElement cloud, string? appType)
    {
        if (appType?.Equals("btp", StringComparison.OrdinalIgnoreCase) == true)
        {
            return cloud.TryGetProperty("secretsManager", out var sm)
                && sm.TryGetProperty("name", out _)
                && sm.TryGetProperty("keys", out var keys)
                && keys.GetArrayLength() > 0;
        }
        if (cloud.TryGetProperty("awsAccountId", out _))
            return true;
        if (cloud.TryGetProperty("azureSubscriptionId", out _))
            return true;
        return false;
    }

    private async Task<JsonElement?> CallApiAsync(string url, CancellationToken ct)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", Token);
        request.Headers.UserAgent.Add(new ProductInfoHeaderValue("EPIC-API", "1.0"));
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github+json"));

        var response = await httpClient.SendAsync(request, ct);

        if (response.StatusCode == HttpStatusCode.NotFound)
            return null;

        if (!response.IsSuccessStatusCode)
        {
            logger.LogWarning("GitHub API returned {StatusCode} for {Url}", (int)response.StatusCode, url);
            return null;
        }

        var body = await response.Content.ReadAsStringAsync(ct);
        return JsonDocument.Parse(body).RootElement;
    }
}
