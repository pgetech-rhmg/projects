using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.Extensions.Caching.Memory;

namespace Epic.Api.Services;

public sealed class GitHubService(HttpClient httpClient, IConfiguration configuration, IGitHubSourceRegistry sources, ILogger<GitHubService> logger, IMemoryCache cache) : IGitHubService
{
    // GitHub reads here back UI previews (config discovery + infra check) and the
    // periodic app refresh — never the actual pipeline trigger, which passes the
    // branch/config straight to ADO and lets the agent re-read epic.json at run
    // time. A short TTL therefore only dedupes bursts (a single branch selection
    // fires getConfigs + checkConfigInfra back-to-back, and the recursive tree is
    // requested by both) without changing what any run does. Matches the 30s
    // volatile-data TTL AdoService uses.
    private static readonly TimeSpan ApiCacheTtl = TimeSpan.FromSeconds(30);

    // Resolves the PAT for a source from configuration by its TokenKey.
    private string TokenFor(GitHubSource source) =>
        configuration[source.TokenKey]
        ?? throw new InvalidOperationException($"GitHub token '{source.TokenKey}' for source '{source.Name}' not configured.");

    // Builds the repo API root for a source, e.g. https://api.github.com/repos/pgetech/foo
    // or https://github.pge.com/api/v3/repos/PGEDigitalCatalyst/foo.
    private static string RepoBase(GitHubSource source, string repo) =>
        $"{source.ApiBase}/repos/{source.Org}/{EscapeSegment(repo)}";

    // Repo/branch/path segments originate from user input (repo name, selected
    // branch, config path). Percent-encode them before splicing into the GitHub
    // API URL so a crafted value can't traverse to a different path/host
    // (defends the SSRF/path-injection hotspot — SonarQube S7044). A repo name
    // has no path separators, so it escapes as a single segment; a file path may
    // contain '/', so each segment is escaped individually with the slashes kept.
    private static string EscapeSegment(string value) => Uri.EscapeDataString(value);
    private static string EscapePath(string path) =>
        string.Join('/', path.Split('/').Select(Uri.EscapeDataString));

    public async Task<GitHubRepoInfo> GetRepoAsync(string repo, string? source = null, CancellationToken ct = default)
    {
        var src = sources.Resolve(source);
        var repoJson = await CallApiAsync(src, $"{RepoBase(src, repo)}", ct);

        if (repoJson is null)
            return new GitHubRepoInfo { Exists = false };

        var repo_ = repoJson.Value;

        var language = repo_.TryGetProperty("language", out var langProp) && langProp.ValueKind != JsonValueKind.Null
            ? langProp.GetString()
            : null;

        // If no primary language, try the languages endpoint for more detail
        if (string.IsNullOrEmpty(language))
        {
            var languagesJson = await CallApiAsync(src, $"{RepoBase(src, repo)}/languages", ct);
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

    public async Task<bool> PathExistsAsync(string repo, string path, string branch, string? source = null, CancellationToken ct = default)
    {
        var src = sources.Resolve(source);
        return await PathExistsAsync(src, repo, path, branch, ct);
    }

    private async Task<bool> PathExistsAsync(GitHubSource src, string repo, string path, string branch, CancellationToken ct)
    {
        var url = $"{RepoBase(src, repo)}/contents/{EscapePath(path)}?ref={Uri.EscapeDataString(branch)}";
        var json = await CallApiAsync(src, url, ct);
        return json is not null;
    }

    public async Task<string?> GetFileContentAsync(string repo, string path, string branch, string? source = null, CancellationToken ct = default)
    {
        var src = sources.Resolve(source);
        return await GetFileContentAsync(src, repo, path, branch, ct);
    }

    private async Task<string?> GetFileContentAsync(GitHubSource src, string repo, string path, string branch, CancellationToken ct)
    {
        var url = $"{RepoBase(src, repo)}/contents/{EscapePath(path)}?ref={Uri.EscapeDataString(branch)}";
        var json = await CallApiAsync(src, url, ct);
        if (json is null) return null;

        var encoding = json.Value.TryGetProperty("encoding", out var enc) ? enc.GetString() : null;
        var content = json.Value.TryGetProperty("content", out var c) ? c.GetString() : null;

        if (encoding == "base64" && content is not null)
            return System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(content));

        return content;
    }

    public async Task<List<string>> FindEpicConfigsAsync(string repo, string branch, string? source = null, CancellationToken ct = default)
    {
        var src = sources.Resolve(source);
        var url = $"{RepoBase(src, repo)}/git/trees/{Uri.EscapeDataString(branch)}?recursive=1";
        var json = await CallApiAsync(src, url, ct);
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

    // The subset of epic.json CheckInfraAsync cares about.
    private readonly record struct EpicConfig(
        string InfraPath, string? AppType, string? BuildTestTool,
        string? ScanTool, string? IntegrationTestTool, bool HasInfraParams,
        IReadOnlyList<string> ConfiguredEnvironments, string CloudProvider);

    public async Task<ConfigCheckResult> CheckInfraAsync(string repo, string branch, string configPath, string? source = null, CancellationToken ct = default)
    {
        var src = sources.Resolve(source);
        var cfg = await ReadEpicConfigAsync(src, repo, branch, configPath, ct);

        var resolved = cfg.InfraPath.TrimStart('/');
        var hasInfra = await PathExistsAsync(src, repo, resolved, branch, ct);
        // Only worth scanning the Terraform sources when an infra folder exists.
        // The remote backend EPIC manages is cloud-specific (azurerm for Azure,
        // s3 for AWS/SAP), so the scan is told which cloud the config targets.
        var (hasRemoteBackend, hasTfState) = hasInfra
            ? await ScanInfraTerraformAsync(src, repo, branch, resolved, cfg.CloudProvider, ct)
            : (false, false);
        return new ConfigCheckResult
        {
            HasInfra = hasInfra,
            HasInfraParams = cfg.HasInfraParams,
            AppType = cfg.AppType,
            BuildTestTool = cfg.BuildTestTool,
            ScanTool = cfg.ScanTool,
            IntegrationTestTool = cfg.IntegrationTestTool,
            HasRemoteBackend = hasRemoteBackend,
            ExpectedBackend = ExpectedBackendFor(cfg.CloudProvider),
            HasTfState = hasTfState,
            ConfiguredEnvironments = cfg.ConfiguredEnvironments
        };
    }

    // Fetches + parses the fields CheckInfraAsync needs from epic.json, returning
    // safe defaults if the file is missing or unparseable.
    // Default infra folder when epic.json doesn't specify one.
    private const string DefaultInfraPath = ".infra";

    private async Task<EpicConfig> ReadEpicConfigAsync(GitHubSource src, string repo, string branch, string configPath, CancellationToken ct)
    {
        try
        {
            var content = await GetFileContentAsync(src, repo, configPath, branch, ct);
            if (content is not null)
                return ParseEpicConfig(System.Text.Json.JsonDocument.Parse(content).RootElement);
        }
        catch (Exception ex)
        {
            logger.LogDebug(ex, "Failed to parse epic.json for {Repo}@{Branch} — using defaults", repo, branch);
        }
        return new EpicConfig(DefaultInfraPath, null, null, null, null, false, [], DefaultCloudProvider);
    }

    // Reads the fields CheckInfraAsync cares about out of a parsed epic.json.
    private static EpicConfig ParseEpicConfig(JsonElement doc)
    {
        string? appType = null, buildTestTool = null, scanTool = null, integrationTestTool = null;
        string? infraPath;

        if (doc.TryGetProperty("app", out var app))
        {
            infraPath = GetStringProp(app, "infraPath");
            appType = GetStringProp(app, "appType");
            buildTestTool = GetStringProp(app, "buildTestTool");
            scanTool = GetStringProp(app, "scanTool");
            integrationTestTool = GetStringProp(app, "integrationTestTool");
        }
        else
        {
            infraPath = GetStringProp(doc, "infraPath");
        }

        var hasCloud = doc.TryGetProperty("cloud", out var cloud);
        var hasInfraParams = hasCloud && HasInfraParamsForAppType(cloud, appType);

        // Environment keys under cloud.environments (per-env connection/RG map),
        // used by the UI to restrict the env dropdown to configured values.
        var configuredEnvironments = hasCloud
            && cloud.TryGetProperty("environments", out var envs)
            && envs.ValueKind == JsonValueKind.Object
            ? envs.EnumerateObject().Select(p => p.Name).ToArray()
            : [];

        var cloudProvider = DetectCloudProvider(appType, hasCloud ? cloud : (JsonElement?)null);

        return new EpicConfig(infraPath ?? DefaultInfraPath, appType, buildTestTool, scanTool, integrationTestTool, hasInfraParams, configuredEnvironments, cloudProvider);
    }

    // EPIC's default cloud when epic.json gives no signal — matches the
    // orchestrator's `else "aws"` fallback.
    private const string DefaultCloudProvider = "aws";

    // Mirrors the cloud-detection ladder in epic-orchestrator.yml so the
    // pre-flight check picks the same expected backend the pipeline will inject:
    //   btp/cap -> sap; awsAccountId -> aws; an Azure service connection or
    //   subscription (flat OR per-environment) -> azure; else aws.
    private static string DetectCloudProvider(string? appType, JsonElement? cloud)
    {
        if (appType is not null &&
            (appType.Equals("btp", StringComparison.OrdinalIgnoreCase)
             || appType.Equals("cap", StringComparison.OrdinalIgnoreCase)))
            return "sap";

        if (cloud is not { } c)
            return DefaultCloudProvider;

        if (c.TryGetProperty("awsAccountId", out _))
            return "aws";
        if (c.TryGetProperty("azureServiceConnection", out _))
            return "azure";
        if (c.TryGetProperty("azureSubscriptionId", out _))
            return "azure";
        if (c.TryGetProperty("environments", out var envs) && envs.ValueKind == JsonValueKind.Object
            && envs.EnumerateObject().Any(e =>
                e.Value.ValueKind == JsonValueKind.Object
                && (e.Value.TryGetProperty("azureServiceConnection", out _)
                    || e.Value.TryGetProperty("azureSubscriptionId", out _))))
            return "azure";

        return DefaultCloudProvider;
    }

    private static string? GetStringProp(JsonElement obj, string name) =>
        obj.TryGetProperty(name, out var v) ? v.GetString() : null;

    // Cap regex execution so a pathological input can never hang the request
    // thread (defends against catastrophic backtracking — SonarQube S6444).
    private static readonly TimeSpan RegexTimeout = TimeSpan.FromSeconds(2);

    // Matches a `backend "s3" { ... }` declaration (AWS/SAP) or a
    // `backend "azurerm" { ... }` declaration (Azure) — the two remote backends
    // EPIC manages. Only valid inside a `terraform {}` block; tolerant of
    // arbitrary whitespace between tokens. The block name is captured so the
    // caller can require the one matching the config's cloud.
    private static readonly System.Text.RegularExpressions.Regex RemoteBackendRegex =
        new("backend\\s+\"(s3|azurerm)\"\\s*\\{", System.Text.RegularExpressions.RegexOptions.Compiled, RegexTimeout);

    // The Terraform backend EPIC injects for a given cloud at `terraform init`.
    private static string ExpectedBackendFor(string cloudProvider) =>
        cloudProvider.Equals("azure", StringComparison.OrdinalIgnoreCase) ? "azurerm" : "s3";

    /// <summary>
    /// Scans the Terraform project under <paramref name="infraPath"/> for two signals:
    /// whether any <c>.tf</c> file declares the remote backend EPIC manages for
    /// <paramref name="cloudProvider"/> (<c>azurerm</c> for Azure, <c>s3</c> for
    /// AWS/SAP), and whether a committed <c>*.tfstate</c> file exists (which would
    /// trigger Terraform's interactive state-migration prompt on init). One tree
    /// fetch covers both.
    /// </summary>
    private async Task<(bool HasRemoteBackend, bool HasTfState)> ScanInfraTerraformAsync(GitHubSource src, string repo, string branch, string infraPath, string cloudProvider, CancellationToken ct)
    {
        var url = $"{RepoBase(src, repo)}/git/trees/{Uri.EscapeDataString(branch)}?recursive=1";
        var json = await CallApiAsync(src, url, ct);
        if (json is null || !json.Value.TryGetProperty("tree", out var tree))
            return (false, false);

        var (tfFiles, hasTfState) = ClassifyInfraTree(tree, infraPath.Trim('/'));

        // Fetch every .tf file concurrently rather than one-at-a-time: the result
        // (matching backend declared in ANY file) is order-independent, so we trade
        // the first-match short-circuit for parallelism — a large infra folder no
        // longer serializes N round-trips behind a single branch selection.
        var contents = await Task.WhenAll(
            tfFiles.Select(file => GetFileContentAsync(src, repo, file, branch, ct)));
        var expected = ExpectedBackendFor(cloudProvider);
        var hasRemoteBackend = contents.Any(content =>
            content is not null
            && RemoteBackendRegex.Matches(StripHclComments(content))
                .Any(m => string.Equals(m.Groups[1].Value, expected, StringComparison.Ordinal)));

        return (hasRemoteBackend, hasTfState);
    }

    // Walks a recursive git tree, confined to the infra folder, returning the
    // .tf file paths and whether any committed *.tfstate exists.
    private static (List<string> TfFiles, bool HasTfState) ClassifyInfraTree(JsonElement tree, string prefix)
    {
        var tfFiles = new List<string>();
        var hasTfState = false;
        foreach (var item in tree.EnumerateArray())
        {
            var type = item.TryGetProperty("type", out var t) ? t.GetString() : null;
            var path = item.TryGetProperty("path", out var p) ? p.GetString() : null;
            if (type != "blob" || path is null)
                continue;
            // Confine the scan to the resolved infra folder.
            if (path != prefix && !path.StartsWith(prefix + "/", StringComparison.Ordinal))
                continue;
            if (path.EndsWith(".tf", StringComparison.OrdinalIgnoreCase))
                tfFiles.Add(path);
            else if (path.EndsWith(".tfstate", StringComparison.OrdinalIgnoreCase))
                hasTfState = true;
        }
        return (tfFiles, hasTfState);
    }

    // Comment-stripping patterns, compiled once with an execution timeout.
    private static readonly System.Text.RegularExpressions.Regex BlockCommentRegex =
        new("/\\*.*?\\*/", System.Text.RegularExpressions.RegexOptions.Singleline | System.Text.RegularExpressions.RegexOptions.Compiled, RegexTimeout);
    private static readonly System.Text.RegularExpressions.Regex LineCommentRegex =
        new("(#|//).*?$", System.Text.RegularExpressions.RegexOptions.Multiline | System.Text.RegularExpressions.RegexOptions.Compiled, RegexTimeout);

    // Strips HCL/Terraform comments so a commented-out backend block doesn't
    // register as a real one. Handles `#`, `//` line comments and `/* */` blocks.
    private static string StripHclComments(string hcl)
    {
        hcl = BlockCommentRegex.Replace(hcl, string.Empty);
        hcl = LineCommentRegex.Replace(hcl, string.Empty);
        return hcl;
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
        // Azure per-env model: the subscription comes from the service connection,
        // not epic.json, so there's no azureSubscriptionId. The cloud signal is a
        // flat azureServiceConnection OR one under cloud.environments.<env>. This
        // mirrors DetectCloudProvider's ladder so static/per-env Azure apps (e.g.
        // a react SPA with per-env staticStorageAccount) count as having a deploy
        // target. Additive only — never flips an existing true to false.
        if (cloud.TryGetProperty("azureServiceConnection", out _))
            return true;
        if (cloud.TryGetProperty("environments", out var azEnvs) && azEnvs.ValueKind == JsonValueKind.Object
            && azEnvs.EnumerateObject().Any(e =>
                e.Value.ValueKind == JsonValueKind.Object
                && (e.Value.TryGetProperty("azureServiceConnection", out _)
                    || e.Value.TryGetProperty("azureSubscriptionId", out _))))
            return true;
        return false;
    }

    private async Task<JsonElement?> CallApiAsync(GitHubSource source, string url, CancellationToken ct)
    {
        // The URL fully identifies a GitHub GET (host + repo + path/tree + ?ref=branch),
        // so it is a safe cache key — and the host/org prefix keeps two sources'
        // same-named repos distinct. The recursive-tree URL built by
        // FindEpicConfigsAsync and ScanInfraTerraformAsync is byte-identical, so
        // the second tree fetch in a branch selection resolves from cache.
        if (cache.TryGetValue<JsonElement>(url, out var cached))
            return cached;

        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", TokenFor(source));
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
        var element = JsonDocument.Parse(body).RootElement;

        // Cache only successful responses. Missing files/branches (404 → null) stay
        // live so a just-created repo, branch, or .infra folder is picked up at once.
        cache.Set(url, element, new MemoryCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = ApiCacheTtl,
            Size = 1
        });

        return element;
    }
}
