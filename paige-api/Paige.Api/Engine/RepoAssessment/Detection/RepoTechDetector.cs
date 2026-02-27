using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Xml.Linq;

using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Detection;

public static class RepoTechDetector
{
    private const long MaxSignalFileBytes = 256 * 1024; // 256 KB

    public static void PopulateProjectsAndTechnologies(string rootPath, RepositoryGraph graph)
    {
        ArgumentNullException.ThrowIfNull(graph);

        DetectDotNet(rootPath, graph);
        DetectNode(rootPath, graph);
        DetectPython(rootPath, graph);
        DetectJava(rootPath, graph);
        DetectGo(rootPath, graph);
        DetectRust(rootPath, graph);

        DetectRuby(rootPath, graph);
        DetectPhp(rootPath, graph);

        DetectIaC(rootPath, graph);
        DetectContainers(graph);
        DetectCicd(graph);
        DetectOrchestration(graph);

        DeduplicateTechnologies(graph);
    }

    // ---------------------------------------------------------------------
    // .NET
    // ---------------------------------------------------------------------

    private static void DetectDotNet(string rootPath, RepositoryGraph graph)
    {
        foreach (RepositoryFileNode file in graph.Files.Where(f => f.RelativePath.EndsWith(".sln", StringComparison.OrdinalIgnoreCase)))
        {
            graph.Projects.Add(
                new RepositoryProjectNode
                {
                    Id = StableIdFromPath(file.RelativePath),
                    Name = Path.GetFileNameWithoutExtension(file.RelativePath),
                    RelativePath = file.RelativePath,
                    ProjectType = "dotnet-solution",
                    Framework = null,
                    FilePaths = [file.RelativePath]
                });

            AddTech(graph, "framework", ".NET", null, ".sln");
        }

        foreach (RepositoryFileNode file in graph.Files.Where(
                     f =>
                         f.RelativePath.EndsWith(".csproj", StringComparison.OrdinalIgnoreCase) ||
                         f.RelativePath.EndsWith(".fsproj", StringComparison.OrdinalIgnoreCase) ||
                         f.RelativePath.EndsWith(".vbproj", StringComparison.OrdinalIgnoreCase)))
        {
            string fullPath = Path.Combine(rootPath, file.RelativePath.Replace('/', Path.DirectorySeparatorChar));

            if (!TryReadSmallText(fullPath, out string? xmlText) || string.IsNullOrWhiteSpace(xmlText))
            {
                continue;
            }

            string? framework = TryExtractTargetFramework(xmlText);

            graph.Projects.Add(
                new RepositoryProjectNode
                {
                    Id = StableIdFromPath(file.RelativePath),
                    Name = Path.GetFileNameWithoutExtension(file.RelativePath),
                    RelativePath = file.RelativePath,
                    ProjectType = "dotnet-project",
                    Framework = framework,
                    FilePaths = [file.RelativePath]
                });

            AddTech(graph, "framework", ".NET", framework, Path.GetExtension(file.RelativePath));
        }
    }

    private static string? TryExtractTargetFramework(string xmlText)
    {
        try
        {
            XDocument doc = XDocument.Parse(xmlText);

            XElement? tfm = doc.Descendants().FirstOrDefault(e => string.Equals(e.Name.LocalName, "TargetFramework", StringComparison.OrdinalIgnoreCase));

            if (tfm != null && !string.IsNullOrWhiteSpace(tfm.Value))
            {
                return tfm.Value.Trim();
            }

            XElement? tfms = doc.Descendants().FirstOrDefault(e => string.Equals(e.Name.LocalName, "TargetFrameworks", StringComparison.OrdinalIgnoreCase));

            if (tfms != null && !string.IsNullOrWhiteSpace(tfms.Value))
            {
                string first = tfms.Value.Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).FirstOrDefault() ?? "";

                return string.IsNullOrWhiteSpace(first) ? null : first;
            }
        }
        catch
        {
            // Deterministic fallback: no framework.
        }

        return null;
    }

    // ---------------------------------------------------------------------
    // Node
    // ---------------------------------------------------------------------

    private static void DetectNode(string rootPath, RepositoryGraph graph)
    {
        foreach (RepositoryFileNode file in graph.Files)
        {
            if (!file.RelativePath.EndsWith("package.json", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            string fullPath = Path.Combine(rootPath, file.RelativePath.Replace('/', Path.DirectorySeparatorChar));

            if (!TryReadSmallText(fullPath, out string? json) || string.IsNullOrWhiteSpace(json))
            {
                continue;
            }

            graph.Projects.Add(
                new RepositoryProjectNode
                {
                    Id = StableIdFromPath(file.RelativePath),
                    Name = InferNodeProjectName(file.RelativePath, json),
                    RelativePath = file.RelativePath,
                    ProjectType = "node",
                    Framework = null,
                    FilePaths = [file.RelativePath]
                });

            AddTech(graph, "framework", "Node.js", null, "package.json");

            if (json.Contains("\"@angular/core\"", StringComparison.OrdinalIgnoreCase))
            {
                AddTech(graph, "framework", "Angular", null, "package.json");
            }

            if (json.Contains("\"react\"", StringComparison.OrdinalIgnoreCase))
            {
                AddTech(graph, "framework", "React", null, "package.json");
            }
        }
    }

    private static string InferNodeProjectName(string relativePath, string json)
    {
        string dir = Path.GetDirectoryName(relativePath.Replace('\\', '/')) ?? "";

        if (TryExtractJsonStringValue(json, "name", out string? name) && !string.IsNullOrWhiteSpace(name))
        {
            return name.Trim();
        }

        return string.IsNullOrWhiteSpace(dir) ? "node-project" : dir;
    }

    private static bool TryExtractJsonStringValue(string json, string propertyName, out string? value)
    {
        value = null;

        try
        {
            using JsonDocument doc = JsonDocument.Parse(json);

            if (!doc.RootElement.TryGetProperty(propertyName, out JsonElement prop))
            {
                return false;
            }

            if (prop.ValueKind != JsonValueKind.String)
            {
                return false;
            }

            value = prop.GetString();

            return true;
        }
        catch
        {
            return false;
        }
    }

    // ---------------------------------------------------------------------
    // Python
    // ---------------------------------------------------------------------

    private static void DetectPython(string rootPath, RepositoryGraph graph)
    {
        foreach (RepositoryFileNode file in graph.Files)
        {
            if (file.RelativePath.EndsWith("pyproject.toml", StringComparison.OrdinalIgnoreCase) ||
                file.RelativePath.EndsWith("requirements.txt", StringComparison.OrdinalIgnoreCase) ||
                file.RelativePath.EndsWith("setup.py", StringComparison.OrdinalIgnoreCase))
            {
                graph.Projects.Add(
                    new RepositoryProjectNode
                    {
                        Id = StableIdFromPath(file.RelativePath),
                        Name = Path.GetDirectoryName(file.RelativePath.Replace('\\', '/')) ?? "python-project",
                        RelativePath = file.RelativePath,
                        ProjectType = "python",
                        Framework = null,
                        FilePaths = [file.RelativePath]
                    });

                AddTech(graph, "framework", "Python", null, Path.GetFileName(file.RelativePath));
            }
        }
    }

    // ---------------------------------------------------------------------
    // Java
    // ---------------------------------------------------------------------

    private static void DetectJava(string rootPath, RepositoryGraph graph)
    {
        foreach (RepositoryFileNode file in graph.Files)
        {
            if (file.RelativePath.EndsWith("pom.xml", StringComparison.OrdinalIgnoreCase))
            {
                graph.Projects.Add(
                    new RepositoryProjectNode
                    {
                        Id = StableIdFromPath(file.RelativePath),
                        Name = Path.GetDirectoryName(file.RelativePath.Replace('\\', '/')) ?? "maven-project",
                        RelativePath = file.RelativePath,
                        ProjectType = "java-maven",
                        Framework = null,
                        FilePaths = [file.RelativePath]
                    });

                AddTech(graph, "package-manager", "Maven", null, "pom.xml");

                string fullPath = Path.Combine(rootPath, file.RelativePath.Replace('/', Path.DirectorySeparatorChar));

                if (TryReadSmallText(fullPath, out string? xmlText) && !string.IsNullOrWhiteSpace(xmlText) &&
                    xmlText.Contains("<spring-boot", StringComparison.OrdinalIgnoreCase))
                {
                    AddTech(graph, "framework", "Spring Boot", null, "pom.xml");
                }
            }

            if (file.RelativePath.EndsWith("build.gradle", StringComparison.OrdinalIgnoreCase) ||
                file.RelativePath.EndsWith("build.gradle.kts", StringComparison.OrdinalIgnoreCase))
            {
                graph.Projects.Add(
                    new RepositoryProjectNode
                    {
                        Id = StableIdFromPath(file.RelativePath),
                        Name = Path.GetDirectoryName(file.RelativePath.Replace('\\', '/')) ?? "gradle-project",
                        RelativePath = file.RelativePath,
                        ProjectType = "java-gradle",
                        Framework = null,
                        FilePaths = [file.RelativePath]
                    });

                AddTech(graph, "package-manager", "Gradle", null, Path.GetFileName(file.RelativePath));
            }
        }
    }

    // ---------------------------------------------------------------------
    // Go / Rust
    // ---------------------------------------------------------------------

    private static void DetectGo(string rootPath, RepositoryGraph graph)
    {
        foreach (RepositoryFileNode file in graph.Files.Where(f => f.RelativePath.EndsWith("go.mod", StringComparison.OrdinalIgnoreCase)))
        {
            graph.Projects.Add(
                new RepositoryProjectNode
                {
                    Id = StableIdFromPath(file.RelativePath),
                    Name = Path.GetDirectoryName(file.RelativePath.Replace('\\', '/')) ?? "go-project",
                    RelativePath = file.RelativePath,
                    ProjectType = "go",
                    Framework = null,
                    FilePaths = [file.RelativePath]
                });

            AddTech(graph, "framework", "Go", null, "go.mod");
        }
    }

    private static void DetectRust(string rootPath, RepositoryGraph graph)
    {
        foreach (RepositoryFileNode file in graph.Files.Where(f => f.RelativePath.EndsWith("Cargo.toml", StringComparison.OrdinalIgnoreCase)))
        {
            graph.Projects.Add(
                new RepositoryProjectNode
                {
                    Id = StableIdFromPath(file.RelativePath),
                    Name = Path.GetDirectoryName(file.RelativePath.Replace('\\', '/')) ?? "rust-project",
                    RelativePath = file.RelativePath,
                    ProjectType = "rust",
                    Framework = null,
                    FilePaths = [file.RelativePath]
                });

            AddTech(graph, "framework", "Rust", null, "Cargo.toml");
        }
    }

    // ---------------------------------------------------------------------
    // Ruby / PHP
    // ---------------------------------------------------------------------

    private static void DetectRuby(string rootPath, RepositoryGraph graph)
    {
        List<RepositoryFileNode> gemfiles =
            graph.Files
                .Where(f => f.RelativePath.EndsWith("Gemfile", StringComparison.OrdinalIgnoreCase))
                .OrderBy(f => f.RelativePath, StringComparer.OrdinalIgnoreCase)
                .ToList();

        if (gemfiles.Count == 0)
        {
            return;
        }

        AddTech(graph, "framework", "Ruby", null, "Gemfile");

        foreach (RepositoryFileNode file in gemfiles)
        {
            graph.Projects.Add(
                new RepositoryProjectNode
                {
                    Id = StableIdFromPath(file.RelativePath),
                    Name = Path.GetDirectoryName(file.RelativePath.Replace('\\', '/')) ?? "ruby-project",
                    RelativePath = file.RelativePath,
                    ProjectType = "ruby",
                    Framework = null,
                    FilePaths = [file.RelativePath]
                });
        }
    }

    private static void DetectPhp(string rootPath, RepositoryGraph graph)
    {
        List<RepositoryFileNode> composerFiles =
            graph.Files
                .Where(f => f.RelativePath.EndsWith("composer.json", StringComparison.OrdinalIgnoreCase))
                .OrderBy(f => f.RelativePath, StringComparer.OrdinalIgnoreCase)
                .ToList();

        if (composerFiles.Count == 0)
        {
            return;
        }

        AddTech(graph, "package-manager", "Composer", null, "composer.json");
        AddTech(graph, "framework", "PHP", null, "composer.json");

        foreach (RepositoryFileNode file in composerFiles)
        {
            graph.Projects.Add(
                new RepositoryProjectNode
                {
                    Id = StableIdFromPath(file.RelativePath),
                    Name = Path.GetDirectoryName(file.RelativePath.Replace('\\', '/')) ?? "php-project",
                    RelativePath = file.RelativePath,
                    ProjectType = "php",
                    Framework = null,
                    FilePaths = [file.RelativePath]
                });
        }
    }

    // ---------------------------------------------------------------------
    // IaC / Containers / CI-CD / Orchestration
    // ---------------------------------------------------------------------

    private static void DetectIaC(string rootPath, RepositoryGraph graph)
    {
        bool hasTf = graph.Files.Any(f => f.RelativePath.EndsWith(".tf", StringComparison.OrdinalIgnoreCase));
        bool hasTerragrunt = graph.Files.Any(f => f.RelativePath.EndsWith("terragrunt.hcl", StringComparison.OrdinalIgnoreCase));

        if (hasTf || hasTerragrunt)
        {
            string signal = hasTf ? ".tf" : "terragrunt.hcl";

            AddTech(graph, "iac", "Terraform", null, signal);
        }

        if (hasTerragrunt)
        {
            AddTech(graph, "iac", "Terragrunt", null, "terragrunt.hcl");
        }

        if (graph.Files.Any(f => f.RelativePath.EndsWith("template.yaml", StringComparison.OrdinalIgnoreCase)) ||
            graph.Files.Any(f => f.RelativePath.EndsWith("template.yml", StringComparison.OrdinalIgnoreCase)))
        {
            AddTech(graph, "iac", "AWS SAM", null, "template.yml");
        }

        if (graph.Files.Any(f => f.RelativePath.EndsWith(".bicep", StringComparison.OrdinalIgnoreCase)))
        {
            AddTech(graph, "iac", "Bicep", null, ".bicep");
        }

        if (graph.Files.Any(
                f =>
                    f.RelativePath.EndsWith(".yaml", StringComparison.OrdinalIgnoreCase) ||
                    f.RelativePath.EndsWith(".yml", StringComparison.OrdinalIgnoreCase)))
        {
            if (graph.Files.Any(
                    f =>
                        f.RelativePath.Contains("cloudformation", StringComparison.OrdinalIgnoreCase) ||
                        f.RelativePath.Contains("cfn", StringComparison.OrdinalIgnoreCase)))
            {
                AddTech(graph, "iac", "AWS CloudFormation", null, "filename-heuristic");
            }
        }
    }

    private static void DetectContainers(RepositoryGraph graph)
    {
        if (graph.Files.Any(f => f.RelativePath.EndsWith("Dockerfile", StringComparison.OrdinalIgnoreCase)))
        {
            AddTech(graph, "container", "Docker", null, "Dockerfile");
        }

        if (graph.Files.Any(f => f.RelativePath.EndsWith("docker-compose.yml", StringComparison.OrdinalIgnoreCase) ||
                                 f.RelativePath.EndsWith("docker-compose.yaml", StringComparison.OrdinalIgnoreCase)))
        {
            AddTech(graph, "container", "Docker Compose", null, "docker-compose.yml");
        }
    }

    private static void DetectCicd(RepositoryGraph graph)
    {
        if (graph.Files.Any(f => f.RelativePath.Contains(".github/workflows", StringComparison.OrdinalIgnoreCase)))
        {
            AddTech(graph, "cicd", "GitHub Actions", null, ".github/workflows");
        }

        if (graph.Files.Any(f => f.RelativePath.Contains("azure-pipelines", StringComparison.OrdinalIgnoreCase)))
        {
            AddTech(graph, "cicd", "Azure DevOps Pipelines", null, "azure-pipelines");
        }

        if (graph.Files.Any(f => f.RelativePath.EndsWith(".gitlab-ci.yml", StringComparison.OrdinalIgnoreCase)))
        {
            AddTech(graph, "cicd", "GitLab CI", null, ".gitlab-ci.yml");
        }

        if (graph.Files.Any(f => f.RelativePath.Contains("jenkinsfile", StringComparison.OrdinalIgnoreCase)))
        {
            AddTech(graph, "cicd", "Jenkins", null, "Jenkinsfile");
        }
    }

    private static void DetectOrchestration(RepositoryGraph graph)
    {
        if (graph.Files.Any(f => f.RelativePath.Contains("kubernetes", StringComparison.OrdinalIgnoreCase) ||
                                 f.RelativePath.EndsWith(".helm", StringComparison.OrdinalIgnoreCase) ||
                                 f.RelativePath.Contains("/helm/", StringComparison.OrdinalIgnoreCase)))
        {
            AddTech(graph, "orchestration", "Kubernetes", null, "filename-heuristic");
        }
    }

    // ---------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------

    private static void AddTech(RepositoryGraph graph, string category, string name, string? version, string source)
    {
        graph.DetectedTechnologies.Add(
            new DetectedTechnology
            {
                Category = category,
                Name = name,
                Version = version,
                DetectionSource = source
            });
    }

    private static void DeduplicateTechnologies(RepositoryGraph graph)
    {
        // Stable de-dupe: keep the first occurrence in existing order.
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var deduped = new List<DetectedTechnology>();

        foreach (DetectedTechnology t in graph.DetectedTechnologies)
        {
            string key = $"{t.Category}::{t.Name}::{t.Version ?? ""}";

            if (seen.Add(key))
            {
                deduped.Add(t);
            }
        }

        graph.DetectedTechnologies.Clear();
        graph.DetectedTechnologies.AddRange(deduped);
    }

    private static bool TryReadSmallText(string fullPath, out string? text)
    {
        text = null;

        try
        {
            var info = new FileInfo(fullPath);

            if (!info.Exists || info.Length > MaxSignalFileBytes)
            {
                return false;
            }

            text = File.ReadAllText(fullPath, Encoding.UTF8);

            return true;
        }
        catch
        {
            return false;
        }
    }

    private static string StableIdFromPath(string relativePath)
    {
        byte[] bytes = Encoding.UTF8.GetBytes(relativePath.Replace('\\', '/').ToLowerInvariant());

        byte[] hash = SHA256.HashData(bytes);

        return Convert.ToHexString(hash).ToLowerInvariant();
    }
}

