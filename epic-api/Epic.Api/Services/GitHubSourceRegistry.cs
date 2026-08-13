using Microsoft.Extensions.Configuration;

namespace Epic.Api.Services;

/// <summary>
/// A named GitHub origin EPIC can read repos from. Bundles the API base URL
/// (so public github.com and a GitHub Enterprise host can coexist), the owning
/// org, and the config key of the PAT used to authenticate to it.
/// </summary>
/// <param name="Name">Stable identifier stored on the app (e.g. "pgetech", "pgedc").</param>
/// <param name="ApiBase">
/// REST API root, no trailing slash. Public GitHub is <c>https://api.github.com</c>;
/// GitHub Enterprise is <c>https://&lt;host&gt;/api/v3</c>.
/// </param>
/// <param name="Org">GitHub org/owner segment spliced into repo URLs.</param>
/// <param name="TokenKey">Configuration key holding the PAT for this source.</param>
public sealed record GitHubSource(string Name, string ApiBase, string Org, string TokenKey);

/// <summary>
/// Thrown when a request names a GitHub source that isn't configured. Distinct
/// from a generic <see cref="InvalidOperationException"/> so the exception
/// middleware can map it to a 400 (bad client input) rather than a 500 — the
/// <c>?source=</c> query param is user-controlled.
/// </summary>
public sealed class UnknownGitHubSourceException(string name)
    : Exception($"Unknown GitHub source '{name}'.");

public interface IGitHubSourceRegistry
{
    /// <summary>The source used when an app/request doesn't name one (legacy behavior).</summary>
    GitHubSource Default { get; }

    /// <summary>Resolves a source by name; returns <see cref="Default"/> when <paramref name="name"/> is null/blank.</summary>
    GitHubSource Resolve(string? name);

    IReadOnlyCollection<GitHubSource> All { get; }
}

/// <summary>
/// Builds the set of GitHub sources from configuration. Two shapes are supported:
///
/// 1. New multi-source form — a <c>GitHubSources</c> section, one child per source:
///    <code>
///    GitHubSources:pgetech:ApiBase = https://api.github.com
///    GitHubSources:pgetech:Org     = pgetech
///    GitHubSources:pgetech:TokenKey = GITHUB_TOKEN
///    GitHubSources:pgedc:ApiBase   = https://github.pge.com/api/v3
///    GitHubSources:pgedc:Org       = PGEDigitalCatalyst
///    GitHubSources:pgedc:TokenKey  = GITHUB_TOKEN_PGEDC
///    GitHubDefaultSource            = pgetech    (optional; first entry otherwise)
///    </code>
///
/// 2. Legacy single-source form — <c>GITHUB_BASE_URL</c> (e.g. https://github.com/pgetech)
///    + <c>GITHUB_TOKEN</c>. Synthesized into a source named "default" so existing
///    deployments keep working with no config change.
/// </summary>
public sealed class GitHubSourceRegistry : IGitHubSourceRegistry
{
    private readonly Dictionary<string, GitHubSource> _sources;
    private readonly GitHubSource _default;

    public GitHubSourceRegistry(IConfiguration configuration)
    {
        _sources = new(StringComparer.OrdinalIgnoreCase);

        var section = configuration.GetSection("GitHubSources");
        foreach (var child in section.GetChildren())
        {
            var apiBase = child["ApiBase"];
            var org = child["Org"];
            var tokenKey = child["TokenKey"];
            if (string.IsNullOrWhiteSpace(apiBase) || string.IsNullOrWhiteSpace(org) || string.IsNullOrWhiteSpace(tokenKey))
                continue;

            _sources[child.Key] = new GitHubSource(child.Key, apiBase.TrimEnd('/'), org.Trim('/'), tokenKey);
        }

        if (_sources.Count == 0)
        {
            // Fall back to the legacy single-org config so nothing breaks pre-migration.
            var baseUrl = configuration["GITHUB_BASE_URL"]
                ?? throw new InvalidOperationException(
                    "No GitHubSources configured and GITHUB_BASE_URL is not set.");
            var uri = new Uri(baseUrl);
            var org = uri.AbsolutePath.Trim('/');
            // Public github.com → api.github.com; any other host → Enterprise /api/v3.
            var apiBase = uri.Host.Equals("github.com", StringComparison.OrdinalIgnoreCase)
                ? "https://api.github.com"
                : $"{uri.Scheme}://{uri.Host}/api/v3";
            var legacy = new GitHubSource("default", apiBase, org, "GITHUB_TOKEN");
            _sources[legacy.Name] = legacy;
            _default = legacy;
            return;
        }

        // Optional top-level "GitHubDefaultSource" names which source is the
        // default; otherwise the first configured source wins.
        var defaultName = configuration["GitHubDefaultSource"];
        _default = defaultName is not null && _sources.TryGetValue(defaultName, out var named)
            ? named
            : _sources.Values.First();
    }

    public GitHubSource Default => _default;

    public GitHubSource Resolve(string? name) =>
        string.IsNullOrWhiteSpace(name)
            ? _default
            : _sources.TryGetValue(name, out var s)
                ? s
                // "default" is the migration backfill value for apps onboarded
                // before multi-org support. When the config names its sources
                // explicitly (so there's no literal "default" entry), treat it as
                // an alias for the configured default rather than an error — those
                // legacy apps keep resolving to the original org.
                : name.Equals("default", StringComparison.OrdinalIgnoreCase)
                    ? _default
                    : throw new UnknownGitHubSourceException(name);

    public IReadOnlyCollection<GitHubSource> All => _sources.Values;
}
