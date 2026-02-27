using System.Text.Json;
using System.Xml.Linq;

using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Dependencies;

public static class ProjectDependencyExtractor
{
    private const long MaxManifestBytes = 512 * 1024; // 512 KB

    public static void PopulateProjectDependencies(string rootPath, RepositoryGraph graph)
    {
        if (string.IsNullOrWhiteSpace(rootPath))
        {
            throw new ArgumentException("Root path must be provided.", nameof(rootPath));
        }

        ArgumentNullException.ThrowIfNull(graph);

        if (graph.Projects.Count == 0)
        {
            return;
        }

        foreach (RepositoryProjectNode project in graph.Projects.OrderBy(p => p.Id, StringComparer.OrdinalIgnoreCase))
        {
            project.Dependencies = ExtractForProject(rootPath, project);
        }
    }

    private static List<ProjectDependency> ExtractForProject(string rootPath, RepositoryProjectNode project)
    {
        string manifestPath = NormalizePath(project.RelativePath);

        if (string.IsNullOrWhiteSpace(manifestPath))
        {
            return [];
        }

        string fullPath = Path.Combine(rootPath, manifestPath.Replace('/', Path.DirectorySeparatorChar));

        if (!TryReadSmallText(fullPath, out string? text) || string.IsNullOrWhiteSpace(text))
        {
            return [];
        }

        List<ProjectDependency> deps = project.ProjectType.ToLowerInvariant() switch
        {
            "dotnet-project" => ExtractDotNetCsproj(manifestPath, text),
            "node" => ExtractNodePackageJson(manifestPath, text),
            "python" => ExtractPythonRequirements(manifestPath, text),
            "java-maven" => ExtractMavenPom(manifestPath, text),
            "go" => ExtractGoMod(manifestPath, text),
            _ => []
        };

        return deps
            .OrderBy(d => d.Ecosystem, StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.Group ?? "", StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.Name, StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.Scope ?? "", StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.Version ?? "", StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.VersionSpec ?? "", StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.SourceManifestPath, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    // ---------------------------------------------------------------------
    // .NET (.csproj)
    // ---------------------------------------------------------------------

    private static List<ProjectDependency> ExtractDotNetCsproj(string manifestPath, string xml)
    {
        try
        {
            XDocument doc = XDocument.Parse(xml);

            List<ProjectDependency> deps =
                doc.Descendants()
                    .Where(e => e.Name.LocalName.Equals("PackageReference", StringComparison.OrdinalIgnoreCase))
                    .Select(
                        e =>
                        {
                            string name =
                                e.Attribute("Include")?.Value
                                ?? e.Attribute("Update")?.Value
                                ?? "";

                            string? versionAttr = e.Attribute("Version")?.Value;

                            string? versionElement =
                                e.Elements()
                                    .FirstOrDefault(x => x.Name.LocalName.Equals("Version", StringComparison.OrdinalIgnoreCase))
                                    ?.Value;

                            string? raw = !string.IsNullOrWhiteSpace(versionAttr) ? versionAttr : versionElement;

                            (string? exact, string? spec) = SplitExactVsSpec(raw);

                            if (string.IsNullOrWhiteSpace(name))
                            {
                                return null;
                            }

                            return new ProjectDependency
                            {
                                Ecosystem = "dotnet",
                                Name = name.Trim(),
                                Version = exact,
                                VersionSpec = spec,
                                Group = null,
                                Scope = null,
                                SourceManifestPath = manifestPath
                            };
                        })
                    .Where(d => d != null)
                    .Cast<ProjectDependency>()
                    .ToList();

            return Deduplicate(deps);
        }
        catch
        {
            return [];
        }
    }

    // ---------------------------------------------------------------------
    // Node (package.json)
    // ---------------------------------------------------------------------

    private static List<ProjectDependency> ExtractNodePackageJson(string manifestPath, string json)
    {
        using JsonDocument? doc = TryParseJson(json);
        if (doc == null)
        {
            return [];
        }

        var deps = new List<ProjectDependency>();

        AddNodeDependencyMap(deps, manifestPath, doc, "dependencies", scope: "prod");
        AddNodeDependencyMap(deps, manifestPath, doc, "devDependencies", scope: "dev");
        AddNodeDependencyMap(deps, manifestPath, doc, "peerDependencies", scope: "peer");
        AddNodeDependencyMap(deps, manifestPath, doc, "optionalDependencies", scope: "optional");

        return Deduplicate(deps);
    }

    private static void AddNodeDependencyMap(
        List<ProjectDependency> deps,
        string manifestPath,
        JsonDocument doc,
        string propertyName,
        string scope)
    {
        if (!doc.RootElement.TryGetProperty(propertyName, out JsonElement map) || map.ValueKind != JsonValueKind.Object)
        {
            return;
        }

        foreach (JsonProperty p in map.EnumerateObject())
        {
            string name = p.Name;
            string? raw = p.Value.ValueKind == JsonValueKind.String ? p.Value.GetString() : null;

            (string? exact, string? spec) = SplitExactVsSpec(raw);

            deps.Add(
                new ProjectDependency
                {
                    Ecosystem = "node",
                    Name = name,
                    Version = exact,
                    VersionSpec = spec,
                    Group = null,
                    Scope = scope,
                    SourceManifestPath = manifestPath
                });
        }
    }

    // ---------------------------------------------------------------------
    // Python (requirements.txt)
    // ---------------------------------------------------------------------

    private static List<ProjectDependency> ExtractPythonRequirements(string manifestPath, string text)
    {
        var deps = new List<ProjectDependency>();

        foreach (string rawLine in text.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None))
        {
            string line = rawLine.Trim();

            if (line.Length == 0)
            {
                continue;
            }

            if (line.StartsWith("#", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            // Skip includes and options (-r, --find-links, etc.)
            if (line.StartsWith("-", StringComparison.OrdinalIgnoreCase) || line.StartsWith("--", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            // Strip inline comments
            int hash = line.IndexOf('#');
            if (hash >= 0)
            {
                line = line.Substring(0, hash).Trim();
            }

            if (line.Length == 0)
            {
                continue;
            }

            // Basic parse: name[extras] ==/<=/>=/~= etc.
            string name;
            string? spec = null;
            string? exact = null;

            string[] ops = ["==", "~=", ">=", "<=", ">", "<", "!="];

            int opIndex = -1;
            string? foundOp = null;

            foreach (string op in ops)
            {
                opIndex = line.IndexOf(op, StringComparison.Ordinal);
                if (opIndex > 0)
                {
                    foundOp = op;
                    break;
                }
            }

            if (foundOp == null)
            {
                name = line;
            }
            else
            {
                name = line.Substring(0, opIndex).Trim();
                string rhs = line.Substring(opIndex).Trim();

                spec = rhs;

                if (foundOp == "==")
                {
                    string v = rhs.Substring(2).Trim();
                    if (!string.IsNullOrWhiteSpace(v))
                    {
                        exact = v;
                        spec = null;
                    }
                }
            }

            name = name.Trim();

            if (string.IsNullOrWhiteSpace(name))
            {
                continue;
            }

            deps.Add(
                new ProjectDependency
                {
                    Ecosystem = "python",
                    Name = name,
                    Version = exact,
                    VersionSpec = spec,
                    Group = null,
                    Scope = null,
                    SourceManifestPath = manifestPath
                });
        }

        return Deduplicate(deps);
    }

    // ---------------------------------------------------------------------
    // Maven (pom.xml)
    // ---------------------------------------------------------------------

    private static List<ProjectDependency> ExtractMavenPom(string manifestPath, string xml)
    {
        try
        {
            XDocument doc = XDocument.Parse(xml);

            List<ProjectDependency> deps =
                doc.Descendants()
                    .Where(e => e.Name.LocalName.Equals("dependency", StringComparison.OrdinalIgnoreCase))
                    .Select(
                        d =>
                        {
                            string? groupId = d.Elements().FirstOrDefault(x => x.Name.LocalName.Equals("groupId", StringComparison.OrdinalIgnoreCase))?.Value?.Trim();
                            string? artifactId = d.Elements().FirstOrDefault(x => x.Name.LocalName.Equals("artifactId", StringComparison.OrdinalIgnoreCase))?.Value?.Trim();
                            string? versionRaw = d.Elements().FirstOrDefault(x => x.Name.LocalName.Equals("version", StringComparison.OrdinalIgnoreCase))?.Value?.Trim();
                            string? scope = d.Elements().FirstOrDefault(x => x.Name.LocalName.Equals("scope", StringComparison.OrdinalIgnoreCase))?.Value?.Trim();

                            if (string.IsNullOrWhiteSpace(artifactId))
                            {
                                return null;
                            }

                            (string? exact, string? spec) = SplitExactVsSpec(versionRaw);

                            return new ProjectDependency
                            {
                                Ecosystem = "java",
                                Name = artifactId,
                                Version = exact,
                                VersionSpec = spec,
                                Group = groupId,
                                Scope = string.IsNullOrWhiteSpace(scope) ? "compile" : scope,
                                SourceManifestPath = manifestPath
                            };
                        })
                    .Where(x => x != null)
                    .Cast<ProjectDependency>()
                    .ToList();

            return Deduplicate(deps);
        }
        catch
        {
            return [];
        }
    }

    // ---------------------------------------------------------------------
    // Go (go.mod)
    // ---------------------------------------------------------------------

    private static List<ProjectDependency> ExtractGoMod(string manifestPath, string text)
    {
        var deps = new List<ProjectDependency>();

        bool inRequireBlock = false;

        foreach (string rawLine in text.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None))
        {
            string line = rawLine.Trim();

            if (line.Length == 0)
            {
                continue;
            }

            int comment = line.IndexOf("//", StringComparison.Ordinal);
            if (comment >= 0)
            {
                line = line.Substring(0, comment).Trim();
            }

            if (line.Length == 0)
            {
                continue;
            }

            if (line.StartsWith("require (", StringComparison.OrdinalIgnoreCase))
            {
                inRequireBlock = true;
                continue;
            }

            if (inRequireBlock && line == ")")
            {
                inRequireBlock = false;
                continue;
            }

            if (line.StartsWith("require ", StringComparison.OrdinalIgnoreCase) && !inRequireBlock)
            {
                string remainder = line.Substring("require ".Length).Trim();
                TryAddGoRequireLine(deps, manifestPath, remainder);
                continue;
            }

            if (inRequireBlock)
            {
                TryAddGoRequireLine(deps, manifestPath, line);
            }
        }

        return Deduplicate(deps);
    }

    private static void TryAddGoRequireLine(List<ProjectDependency> deps, string manifestPath, string line)
    {
        string trimmed = line.Trim();

        if (trimmed.Length == 0)
        {
            return;
        }

        // Format: <module> <version>
        string[] parts = trimmed.Split(' ', StringSplitOptions.RemoveEmptyEntries);

        if (parts.Length < 2)
        {
            return;
        }

        string module = parts[0].Trim();
        string versionRaw = parts[1].Trim();

        if (string.IsNullOrWhiteSpace(module))
        {
            return;
        }

        (string? exact, string? spec) = SplitExactVsSpec(versionRaw);

        deps.Add(
            new ProjectDependency
            {
                Ecosystem = "go",
                Name = module,
                Version = exact,
                VersionSpec = spec,
                Group = null,
                Scope = null,
                SourceManifestPath = manifestPath
            });
    }

    // ---------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------

    private static List<ProjectDependency> Deduplicate(List<ProjectDependency> deps)
    {
        var unique = new Dictionary<string, ProjectDependency>(StringComparer.OrdinalIgnoreCase);

        foreach (ProjectDependency d in deps)
        {
            string key =
                $"{d.Ecosystem}::{d.Group ?? ""}::{d.Name}::{d.Scope ?? ""}::{d.Version ?? ""}::{d.VersionSpec ?? ""}::{d.SourceManifestPath}";

            if (!unique.ContainsKey(key))
            {
                unique[key] = d;
            }
        }

        return unique
            .Values
            .OrderBy(d => d.Ecosystem, StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.Group ?? "", StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.Name, StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.Scope ?? "", StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.Version ?? "", StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.VersionSpec ?? "", StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => d.SourceManifestPath, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private static (string? exact, string? spec) SplitExactVsSpec(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw))
        {
            return (null, null);
        }

        string v = raw.Trim();

        // Treat plain dotted versions as exact, otherwise keep as spec
        bool looksExact =
            v.Length > 0
            && v.All(c => char.IsDigit(c) || c == '.' || c == '-'
                || c == '+'
                || char.IsLetter(c));

        if (looksExact && !v.StartsWith("^", StringComparison.OrdinalIgnoreCase)
            && !v.StartsWith("~", StringComparison.OrdinalIgnoreCase)
            && !v.StartsWith(">", StringComparison.OrdinalIgnoreCase)
            && !v.StartsWith("<", StringComparison.OrdinalIgnoreCase)
            && !v.StartsWith("=", StringComparison.OrdinalIgnoreCase)
            && !v.Contains(" ", StringComparison.OrdinalIgnoreCase)
            && !v.Contains("||", StringComparison.OrdinalIgnoreCase)
            && !v.Contains("*", StringComparison.OrdinalIgnoreCase))
        {
            return (v, null);
        }

        return (null, v);
    }

    private static JsonDocument? TryParseJson(string json)
    {
        try
        {
            return JsonDocument.Parse(json);
        }
        catch
        {
            return null;
        }
    }

    private static bool TryReadSmallText(string fullPath, out string? text)
    {
        text = null;

        try
        {
            FileInfo info = new(fullPath);
            if (!info.Exists)
            {
                return false;
            }

            if (info.Length > MaxManifestBytes)
            {
                return false;
            }

            text = File.ReadAllText(fullPath);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static string NormalizePath(string path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return "";
        }

        return path.Replace('\\', '/').TrimStart('/');
    }
}

