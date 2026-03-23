using System.Net;
using System.Net.Http.Headers;

namespace Epic.Api.Services;

public sealed class GitHubService(HttpClient httpClient, IConfiguration configuration) : IGitHubService
{
    public async Task<bool> RepoExistsAsync(string repo, CancellationToken ct = default)
    {
        var baseUrl = configuration["GITHUB_BASE_URL"]
            ?? throw new InvalidOperationException("GITHUB_BASE_URL not configured.");

        var token = configuration["GITHUB_TOKEN"]
            ?? throw new InvalidOperationException("GITHUB_TOKEN not configured.");

        // baseUrl is the org URL (e.g., https://github.com/pgetech)
        // GitHub API: GET /repos/{owner}/{repo}
        var orgName = new Uri(baseUrl).AbsolutePath.Trim('/');
        var requestUrl = $"https://api.github.com/repos/{orgName}/{repo}";

        using var request = new HttpRequestMessage(HttpMethod.Get, requestUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        request.Headers.UserAgent.Add(new ProductInfoHeaderValue("EPIC-API", "1.0"));
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github+json"));

        var response = await httpClient.SendAsync(request, ct);

        return response.StatusCode switch
        {
            HttpStatusCode.OK => true,
            HttpStatusCode.NotFound => false,
            _ => throw new HttpRequestException($"GitHub API returned {response.StatusCode} for repo '{repo}'")
        };
    }
}
