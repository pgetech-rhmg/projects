using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;

namespace Epic.Api.Services;

public sealed class GitHubService(HttpClient httpClient, IConfiguration configuration) : IGitHubService
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

    private async Task<JsonElement?> CallApiAsync(string url, CancellationToken ct)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", Token);
        request.Headers.UserAgent.Add(new ProductInfoHeaderValue("EPIC-API", "1.0"));
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github+json"));

        var response = await httpClient.SendAsync(request, ct);

        if (response.StatusCode == HttpStatusCode.NotFound)
            return null;

        response.EnsureSuccessStatusCode();

        var body = await response.Content.ReadAsStringAsync(ct);
        return JsonDocument.Parse(body).RootElement;
    }
}
