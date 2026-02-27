using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Linking;

public static class ProjectLinker
{
    public static void LinkFilesToProjects(RepositoryGraph graph)
    {
        ArgumentNullException.ThrowIfNull(graph);

        if (graph.Projects.Count == 0 || graph.Files.Count == 0)
        {
            return;
        }

        NormalizeAndMergeProjects(graph);

        Dictionary<string, ProjectBoundary> boundaries = BuildProjectBoundaries(graph.Projects);

        AssignFiles(graph, boundaries);

        PopulateProjectFilePaths(graph);
    }

    private static void NormalizeAndMergeProjects(RepositoryGraph graph)
    {
        // Merge duplicate detections for the same project type rooted in the same directory.
        // Example: requirements.txt + pyproject.toml in the same folder should be one python project boundary.
        Dictionary<string, List<RepositoryProjectNode>> byKey =
            graph.Projects
                .GroupBy(p => GetMergeKey(p), StringComparer.OrdinalIgnoreCase)
                .ToDictionary(g => g.Key, g => g.ToList(), StringComparer.OrdinalIgnoreCase);

        var merged = new List<RepositoryProjectNode>();

        foreach (KeyValuePair<string, List<RepositoryProjectNode>> kvp in byKey.OrderBy(k => k.Key, StringComparer.OrdinalIgnoreCase))
        {
            List<RepositoryProjectNode> group = kvp.Value;

            RepositoryProjectNode primary =
                group
                    .OrderBy(p => p.Id, StringComparer.OrdinalIgnoreCase)
                    .First();

            HashSet<string> manifestPaths = new(StringComparer.OrdinalIgnoreCase);

            foreach (RepositoryProjectNode p in group)
            {
                if (!string.IsNullOrWhiteSpace(p.RelativePath))
                {
                    manifestPaths.Add(NormalizePath(p.RelativePath));
                }

                foreach (string seeded in p.FilePaths)
                {
                    if (!string.IsNullOrWhiteSpace(seeded))
                    {
                        manifestPaths.Add(NormalizePath(seeded));
                    }
                }
            }

            string? framework =
                group
                    .Select(p => p.Framework)
                    .Where(v => !string.IsNullOrWhiteSpace(v))
                    .OrderBy(v => v, StringComparer.OrdinalIgnoreCase)
                    .FirstOrDefault();

            primary.Framework = framework;

            // Seed FilePaths with manifest(s) only. The full file list is populated after linking.
            primary.FilePaths =
                manifestPaths
                    .OrderBy(p => p, StringComparer.OrdinalIgnoreCase)
                    .ToList();

            merged.Add(primary);
        }

        graph.Projects.Clear();
        graph.Projects.AddRange(merged);
    }

    private static string GetMergeKey(RepositoryProjectNode project)
    {
        string rootDir = GetProjectRootDir(project);

        return $"{project.ProjectType}::{rootDir}";
    }

    private static Dictionary<string, ProjectBoundary> BuildProjectBoundaries(IReadOnlyList<RepositoryProjectNode> projects)
    {
        var boundaries = new Dictionary<string, ProjectBoundary>(StringComparer.OrdinalIgnoreCase);

        foreach (RepositoryProjectNode p in projects)
        {
            string rootDir = GetProjectRootDir(p);

            boundaries[p.Id] =
                new ProjectBoundary
                {
                    ProjectId = p.Id,
                    ProjectType = p.ProjectType,
                    RootDir = rootDir,
                    RootDepth = rootDir.Length == 0 ? 0 : rootDir.Split('/').Length,
                    ManifestPaths =
                        p.FilePaths
                            .Select(NormalizePath)
                            .Where(v => !string.IsNullOrWhiteSpace(v))
                            .Distinct(StringComparer.OrdinalIgnoreCase)
                            .OrderBy(v => v, StringComparer.OrdinalIgnoreCase)
                            .ToList()
                };
        }

        return boundaries;
    }

    private static void AssignFiles(RepositoryGraph graph, Dictionary<string, ProjectBoundary> boundaries)
    {
        List<ProjectBoundary> allBoundaries =
            boundaries
                .Values
                .OrderByDescending(b => b.RootDepth)
                .ThenBy(b => b.ProjectId, StringComparer.OrdinalIgnoreCase)
                .ToList();

        foreach (RepositoryFileNode file in graph.Files)
        {
            string filePath = NormalizePath(file.RelativePath);

            List<ProjectBoundary> candidates = GetCandidateProjects(filePath, allBoundaries);

            if (candidates.Count == 0)
            {
                file.ProjectId = null;
                continue;
            }

            ProjectBoundary best = SelectBestProject(file, filePath, candidates);

            file.ProjectId = best.ProjectId;
        }
    }

    private static List<ProjectBoundary> GetCandidateProjects(string filePath, IEnumerable<ProjectBoundary> boundaries)
    {
        var list = new List<ProjectBoundary>();

        foreach (ProjectBoundary b in boundaries)
        {
            if (IsContainedWithin(filePath, b.RootDir))
            {
                list.Add(b);
            }
        }

        return list;
    }

    private static ProjectBoundary SelectBestProject(
        RepositoryFileNode file,
        string filePath,
        IReadOnlyList<ProjectBoundary> candidates)
    {
        ProjectBoundary? best = null;
        int bestScore = int.MinValue;

        foreach (ProjectBoundary candidate in candidates)
        {
            int score = 0;

            // 1) Exact manifest match always wins for that manifest file
            if (candidate.ManifestPaths.Any(p => filePath.Equals(p, StringComparison.OrdinalIgnoreCase)))
            {
                score += 10_000;
            }

            // 2) Prefer language-affinity projects when multiple project types overlap
            score += GetLanguageAffinityScore(file, candidate.ProjectType);

            // 3) Prefer deeper (more specific) project roots
            score += candidate.RootDepth * 10;

            // 4) Prefer roots closer to the file
            score += GetRootContainmentSpecificityScore(filePath, candidate.RootDir);

            if (best == null || score > bestScore)
            {
                best = candidate;
                bestScore = score;
                continue;
            }

            if (score == bestScore)
            {
                if (string.Compare(candidate.ProjectId, best.ProjectId, StringComparison.OrdinalIgnoreCase) < 0)
                {
                    best = candidate;
                }
            }
        }

        return best!;
    }

    private static int GetLanguageAffinityScore(RepositoryFileNode file, string projectType)
    {
        string ext = file.Extension ?? "";

        if (string.IsNullOrWhiteSpace(ext) && !string.IsNullOrWhiteSpace(file.RelativePath))
        {
            ext = Path.GetExtension(file.RelativePath);
        }

        ext = ext.StartsWith('.') ? ext[1..] : ext;

        string language = file.Language ?? "";

        // .NET
        if (projectType.StartsWith("dotnet", StringComparison.OrdinalIgnoreCase))
        {
            if (ext.Equals("cs", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("fs", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("vb", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("csproj", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("fsproj", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("vbproj", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("sln", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("props", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("targets", StringComparison.OrdinalIgnoreCase))
            {
                return 2000;
            }

            if (language.Equals("C#", StringComparison.OrdinalIgnoreCase) ||
                language.Equals("F#", StringComparison.OrdinalIgnoreCase) ||
                language.Equals("VB.NET", StringComparison.OrdinalIgnoreCase))
            {
                return 2000;
            }

            return 0;
        }

        // Node / JS ecosystem
        if (projectType.Equals("node", StringComparison.OrdinalIgnoreCase))
        {
            if (ext.Equals("js", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("jsx", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("ts", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("tsx", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("json", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("mjs", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("cjs", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("css", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("scss", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("html", StringComparison.OrdinalIgnoreCase))
            {
                return 1500;
            }

            if (language.Equals("TypeScript", StringComparison.OrdinalIgnoreCase) ||
                language.Equals("JavaScript", StringComparison.OrdinalIgnoreCase))
            {
                return 1500;
            }

            return 0;
        }

        // Python
        if (projectType.Equals("python", StringComparison.OrdinalIgnoreCase))
        {
            if (ext.Equals("py", StringComparison.OrdinalIgnoreCase))
            {
                return 1400;
            }

            if (language.Equals("Python", StringComparison.OrdinalIgnoreCase))
            {
                return 1400;
            }

            return 0;
        }

        // Java
        if (projectType.StartsWith("java", StringComparison.OrdinalIgnoreCase))
        {
            if (ext.Equals("java", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("kt", StringComparison.OrdinalIgnoreCase) ||
                ext.Equals("kts", StringComparison.OrdinalIgnoreCase))
            {
                return 1300;
            }

            if (language.Equals("Java", StringComparison.OrdinalIgnoreCase) ||
                language.Equals("Kotlin", StringComparison.OrdinalIgnoreCase))
            {
                return 1300;
            }

            return 0;
        }

        // Go
        if (projectType.Equals("go", StringComparison.OrdinalIgnoreCase))
        {
            if (ext.Equals("go", StringComparison.OrdinalIgnoreCase))
            {
                return 1200;
            }

            if (language.Equals("Go", StringComparison.OrdinalIgnoreCase))
            {
                return 1200;
            }

            return 0;
        }

        // Rust
        if (projectType.Equals("rust", StringComparison.OrdinalIgnoreCase))
        {
            if (ext.Equals("rs", StringComparison.OrdinalIgnoreCase))
            {
                return 1100;
            }

            if (language.Equals("Rust", StringComparison.OrdinalIgnoreCase))
            {
                return 1100;
            }

            return 0;
        }

        return 0;
    }

    private static int GetRootContainmentSpecificityScore(string filePath, string rootDir)
    {
        if (string.IsNullOrWhiteSpace(rootDir))
        {
            return 0;
        }

        string normalizedRoot = NormalizePath(rootDir).TrimEnd('/');

        if (!filePath.StartsWith(normalizedRoot, StringComparison.OrdinalIgnoreCase))
        {
            return 0;
        }

        // Prefer a root that is closer (shorter remaining suffix) to the file
        int remaining = filePath.Length - normalizedRoot.Length;

        if (remaining <= 0)
        {
            return 0;
        }

        int scaled = Math.Min(remaining, 500);

        return 500 - scaled;
    }

    private static bool IsContainedWithin(string filePath, string rootDir)
    {
        if (string.IsNullOrWhiteSpace(rootDir))
        {
            return true;
        }

        string normalizedRoot = NormalizePath(rootDir).TrimEnd('/');

        if (normalizedRoot.Length == 0)
        {
            return true;
        }

        if (filePath.Equals(normalizedRoot, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        return filePath.StartsWith(normalizedRoot + "/", StringComparison.OrdinalIgnoreCase);
    }

    private static void PopulateProjectFilePaths(RepositoryGraph graph)
    {
        Dictionary<string, List<string>> byProjectId = new(StringComparer.OrdinalIgnoreCase);

        foreach (RepositoryFileNode file in graph.Files)
        {
            if (string.IsNullOrWhiteSpace(file.ProjectId))
            {
                continue;
            }

            if (!byProjectId.TryGetValue(file.ProjectId, out List<string>? list))
            {
                list = [];
                byProjectId[file.ProjectId] = list;
            }

            list.Add(NormalizePath(file.RelativePath));
        }

        foreach (RepositoryProjectNode project in graph.Projects)
        {
            var merged = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            // Keep any manifest paths seeded during detection/merge
            foreach (string p in project.FilePaths)
            {
                if (!string.IsNullOrWhiteSpace(p))
                {
                    merged.Add(NormalizePath(p));
                }
            }

            if (byProjectId.TryGetValue(project.Id, out List<string>? assigned))
            {
                foreach (string p in assigned)
                {
                    merged.Add(NormalizePath(p));
                }
            }

            project.FilePaths =
                merged
                    .OrderBy(p => p, StringComparer.OrdinalIgnoreCase)
                    .ToList();
        }
    }

    private static string GetProjectRootDir(RepositoryProjectNode project)
    {
        string manifestPath = NormalizePath(project.RelativePath);

        string? dir = Path.GetDirectoryName(manifestPath.Replace('/', Path.DirectorySeparatorChar));

        if (string.IsNullOrWhiteSpace(dir))
        {
            return "";
        }

        return NormalizePath(dir);
    }

    private static string NormalizePath(string path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return "";
        }

        return path.Replace('\\', '/').TrimStart('/');
    }

    private sealed class ProjectBoundary
    {
        public string ProjectId { get; init; } = "";

        public string ProjectType { get; init; } = "";

        public string RootDir { get; init; } = "";

        public int RootDepth { get; init; }

        public List<string> ManifestPaths { get; init; } = [];
    }
}

