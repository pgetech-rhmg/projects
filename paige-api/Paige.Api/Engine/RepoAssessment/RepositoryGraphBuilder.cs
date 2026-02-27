using System.Security.Cryptography;
using System.Text;

using Paige.Api.Engine.Common;
using Paige.Api.Engine.RepoAssessment.Dependencies;
using Paige.Api.Engine.RepoAssessment.Detection;
using Paige.Api.Engine.RepoAssessment.Linking;
using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment;

public sealed class RepositoryGraphBuilder
{
    private readonly IFileScanner _fileScanner;

    public RepositoryGraphBuilder(IFileScanner fileScanner)
    {
        _fileScanner = fileScanner;
    }

    public RepositoryGraph Build(string rootPath)
    {
        if (string.IsNullOrWhiteSpace(rootPath))
        {
            throw new ArgumentException("Root path must be provided.", nameof(rootPath));
        }

        IReadOnlyList<ScannedFile> scanned = _fileScanner.Scan(rootPath, includeContent: false);

        var graph = new RepositoryGraph();

        graph.Metadata.RootPath = rootPath;
        graph.Metadata.RepositoryName = GetRepositoryName(rootPath);
        graph.Metadata.AssessedAtUtc = DateTimeOffset.UtcNow;

        foreach (ScannedFile file in scanned)
        {
            graph.Files.Add(
                new RepositoryFileNode
                {
                    RelativePath = file.RelativePath,
                    Extension = file.Extension,
                    SizeBytes = file.SizeBytes,
                    IsBinary = file.IsBinary,
                    Sha256 = file.Sha256,
                    LineCount = file.LineCount,
                    Language = LanguageRegistry.DetectLanguage(file.Extension),
                    ProjectId = null
                });
        }

        graph.Metrics = ComputeMetrics(graph.Files);

        graph.Metadata.RepositoryHash = ComputeRepositoryHash(graph.Files);

        PopulateLanguageTechnologies(graph);

        RepoTechDetector.PopulateProjectsAndTechnologies(rootPath, graph);

        ProjectLinker.LinkFilesToProjects(graph);

        ComputeProjectMetrics(graph);

        ProjectDependencyExtractor.PopulateProjectDependencies(rootPath, graph);

        ComputeProjectDependencySummaries(graph);
        ComputeRepositoryDependencySummary(graph);
        ComputeRepositoryStructuralSignals(graph);
        ComputeRepositoryArchitectureSignals(graph);
        ComputeProjectModernizationSignals(graph);
        ComputeRepositoryModernizationSignals(graph);

        return graph;
    }

    private static void ComputeRepositoryDependencySummary(RepositoryGraph graph)
    {
        var projects = graph.Projects;

        int totalProjects = projects.Count;

        int totalDeps = 0;
        int prod = 0;
        int dev = 0;
        int test = 0;
        int peer = 0;
        int optional = 0;
        int other = 0;

        int exact = 0;
        int spec = 0;
        int unspecified = 0;

        long totalLoc = projects.Sum(p => (long)p.Metrics.TotalLinesOfCode);

        var ecosystemCounts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

        foreach (RepositoryProjectNode project in projects.OrderBy(p => p.Id, StringComparer.OrdinalIgnoreCase))
        {
            var summary = project.DependencySummary;

            totalDeps += summary.TotalDependencyCount;

            prod += summary.ProdDependencyCount;
            dev += summary.DevDependencyCount;
            test += summary.TestDependencyCount;
            peer += summary.PeerDependencyCount;
            optional += summary.OptionalDependencyCount;
            other += summary.OtherDependencyCount;

            exact += summary.ExactVersionCount;
            spec += summary.VersionSpecCount;
            unspecified += summary.UnspecifiedVersionCount;

            foreach (var eco in summary.EcosystemCounts)
            {
                if (!ecosystemCounts.ContainsKey(eco.Ecosystem))
                {
                    ecosystemCounts[eco.Ecosystem] = 0;
                }

                ecosystemCounts[eco.Ecosystem] += eco.Count;
            }
        }

        double? perKLoc = null;

        if (totalLoc > 0)
        {
            perKLoc = totalDeps / (totalLoc / 1000.0);
        }

        var ecosystemList =
            ecosystemCounts
                .Select(kvp => new RepositoryEcosystemDependencyCount
                {
                    Ecosystem = kvp.Key,
                    Count = kvp.Value
                })
                .OrderByDescending(x => x.Count)
                .ThenBy(x => x.Ecosystem, StringComparer.OrdinalIgnoreCase)
                .ToList();

        var topProjects =
            projects
                .Select(p => new RepositoryProjectDependencyRanking
                {
                    ProjectId = p.Id,
                    ProjectName = p.Name,
                    DependencyCount = p.DependencySummary.TotalDependencyCount
                })
                .OrderByDescending(x => x.DependencyCount)
                .ThenBy(x => x.ProjectName, StringComparer.OrdinalIgnoreCase)
                .ToList();

        graph.DependencySummary =
            new RepositoryDependencySummary
            {
                TotalProjects = totalProjects,

                TotalDependencyCount = totalDeps,

                ProdDependencyCount = prod,
                DevDependencyCount = dev,
                TestDependencyCount = test,
                PeerDependencyCount = peer,
                OptionalDependencyCount = optional,
                OtherDependencyCount = other,

                ExactVersionCount = exact,
                VersionSpecCount = spec,
                UnspecifiedVersionCount = unspecified,

                DependenciesPerKLoc = perKLoc,

                EcosystemCounts = ecosystemList,
                TopProjectsByDependencyCount = topProjects
            };
    }

    private static void ComputeProjectDependencySummaries(RepositoryGraph graph)
    {
        foreach (RepositoryProjectNode project in graph.Projects.OrderBy(p => p.Id, StringComparer.OrdinalIgnoreCase))
        {
            IReadOnlyList<ProjectDependency> deps = project.Dependencies;

            int total = deps.Count;

            int prod = 0;
            int dev = 0;
            int test = 0;
            int peer = 0;
            int optional = 0;
            int other = 0;

            foreach (ProjectDependency d in deps)
            {
                string scope = (d.Scope ?? "").Trim();

                if (scope.Length == 0)
                {
                    prod++;
                    continue;
                }

                if (scope.Equals("prod", StringComparison.OrdinalIgnoreCase) ||
                    scope.Equals("production", StringComparison.OrdinalIgnoreCase) ||
                    scope.Equals("compile", StringComparison.OrdinalIgnoreCase) ||
                    scope.Equals("runtime", StringComparison.OrdinalIgnoreCase))
                {
                    prod++;
                    continue;
                }

                if (scope.Equals("dev", StringComparison.OrdinalIgnoreCase) ||
                    scope.Equals("development", StringComparison.OrdinalIgnoreCase))
                {
                    dev++;
                    continue;
                }

                if (scope.Equals("test", StringComparison.OrdinalIgnoreCase) ||
                    scope.Equals("tests", StringComparison.OrdinalIgnoreCase))
                {
                    test++;
                    continue;
                }

                if (scope.Equals("peer", StringComparison.OrdinalIgnoreCase))
                {
                    peer++;
                    continue;
                }

                if (scope.Equals("optional", StringComparison.OrdinalIgnoreCase))
                {
                    optional++;
                    continue;
                }

                other++;
            }

            int exactVersions = deps.Count(d => !string.IsNullOrWhiteSpace(d.Version));
            int versionSpecs = deps.Count(d => !string.IsNullOrWhiteSpace(d.VersionSpec));
            int unspecifiedVersions = deps.Count(d => string.IsNullOrWhiteSpace(d.Version) && string.IsNullOrWhiteSpace(d.VersionSpec));

            List<ProjectEcosystemDependencyCount> ecosystemCounts =
                deps
                    .GroupBy(d => d.Ecosystem ?? "", StringComparer.OrdinalIgnoreCase)
                    .Select(
                        g =>
                            new ProjectEcosystemDependencyCount
                            {
                                Ecosystem = g.Key ?? "",
                                Count = g.Count()
                            })
                    .OrderByDescending(x => x.Count)
                    .ThenBy(x => x.Ecosystem, StringComparer.OrdinalIgnoreCase)
                    .ToList();

            int loc = project.Metrics.TotalLinesOfCode;

            double? perKLoc = null;

            if (loc > 0)
            {
                perKLoc = total / (loc / 1000.0);
            }

            project.DependencySummary =
                new ProjectDependencySummary
                {
                    TotalDependencyCount = total,

                    ProdDependencyCount = prod,
                    DevDependencyCount = dev,
                    TestDependencyCount = test,
                    PeerDependencyCount = peer,
                    OptionalDependencyCount = optional,
                    OtherDependencyCount = other,

                    ExactVersionCount = exactVersions,
                    VersionSpecCount = versionSpecs,
                    UnspecifiedVersionCount = unspecifiedVersions,

                    DependenciesPerKLoc = perKLoc,
                    EcosystemCounts = ecosystemCounts
                };
        }
    }

    private static void ComputeProjectMetrics(RepositoryGraph graph)
    {
        Dictionary<string, List<RepositoryFileNode>> filesByProjectId = new(StringComparer.OrdinalIgnoreCase);

        foreach (RepositoryFileNode file in graph.Files)
        {
            if (string.IsNullOrWhiteSpace(file.ProjectId))
            {
                continue;
            }

            if (!filesByProjectId.TryGetValue(file.ProjectId, out List<RepositoryFileNode>? list))
            {
                list = [];
                filesByProjectId[file.ProjectId] = list;
            }

            list.Add(file);
        }

        foreach (RepositoryProjectNode project in graph.Projects)
        {
            if (!filesByProjectId.TryGetValue(project.Id, out List<RepositoryFileNode>? projectFiles))
            {
                project.Metrics = new ProjectMetrics();
                continue;
            }

            int totalFiles = projectFiles.Count;
            int binaryFiles = projectFiles.Count(f => f.IsBinary);
            int textFiles = totalFiles - binaryFiles;

            long totalSize = 0;
            long totalTextSize = 0;

            int totalLines = 0;

            foreach (RepositoryFileNode f in projectFiles)
            {
                totalSize += f.SizeBytes;

                if (!f.IsBinary)
                {
                    totalTextSize += f.SizeBytes;

                    if (f.LineCount.HasValue)
                    {
                        totalLines += f.LineCount.Value;
                    }
                }
            }

            List<ProjectLanguageMetrics> languages =
                projectFiles
                    .Where(f => !string.IsNullOrWhiteSpace(f.Language))
                    .GroupBy(f => f.Language, StringComparer.OrdinalIgnoreCase)
                    .Select(
                        g =>
                            new ProjectLanguageMetrics
                            {
                                Language = g.Key ?? "",
                                FileCount = g.Count(),
                                LinesOfCode = g.Where(x => !x.IsBinary && x.LineCount.HasValue).Sum(x => x.LineCount.GetValueOrDefault())
                            })
                    .OrderByDescending(x => x.FileCount)
                    .ThenBy(x => x.Language, StringComparer.OrdinalIgnoreCase)
                    .ToList();

            project.Metrics =
                new ProjectMetrics
                {
                    TotalFiles = totalFiles,
                    TextFiles = textFiles,
                    BinaryFiles = binaryFiles,
                    TotalSizeBytes = totalSize,
                    TotalTextSizeBytes = totalTextSize,
                    TotalLinesOfCode = totalLines,
                    Languages = languages
                };
        }
    }

    private static RepositoryMetrics ComputeMetrics(IReadOnlyList<RepositoryFileNode> files)
    {
        int totalFiles = files.Count;
        int binaryFiles = files.Count(f => f.IsBinary);
        int textFiles = totalFiles - binaryFiles;

        long totalSize = 0;
        long totalTextSize = 0;

        int totalLines = 0;

        foreach (RepositoryFileNode f in files)
        {
            totalSize += f.SizeBytes;

            if (!f.IsBinary)
            {
                totalTextSize += f.SizeBytes;

                if (f.LineCount.HasValue)
                {
                    totalLines += f.LineCount.Value;
                }
            }
        }

        return new RepositoryMetrics
        {
            TotalFiles = totalFiles,
            TextFiles = textFiles,
            BinaryFiles = binaryFiles,
            TotalSizeBytes = totalSize,
            TotalTextSizeBytes = totalTextSize,
            TotalLinesOfCode = totalLines
        };
    }

    private static string ComputeRepositoryHash(IReadOnlyList<RepositoryFileNode> files)
    {
        List<RepositoryFileNode> ordered =
            files
                .OrderBy(f => f.RelativePath, StringComparer.OrdinalIgnoreCase)
                .ToList();

        using SHA256 sha = SHA256.Create();

        foreach (RepositoryFileNode f in ordered)
        {
            string line = $"{f.RelativePath}|{f.SizeBytes}|{f.Sha256}\n";
            byte[] bytes = Encoding.UTF8.GetBytes(line);

            sha.TransformBlock(bytes, 0, bytes.Length, null, 0);
        }

        sha.TransformFinalBlock([], 0, 0);

        return Convert.ToHexString(sha.Hash!).ToLowerInvariant();
    }

    private static void PopulateLanguageTechnologies(RepositoryGraph graph)
    {
        var languages =
            graph.Files
                .Where(f => !string.IsNullOrWhiteSpace(f.Language))
                .GroupBy(f => f.Language)
                .OrderByDescending(g => g.Count());

        foreach (var group in languages)
        {
            graph.DetectedTechnologies.Add(
                new DetectedTechnology
                {
                    Category = "language",
                    Name = group.Key!,
                    Version = null,
                    DetectionSource = "file-extension"
                });
        }
    }

    private static string GetRepositoryName(string rootPath)
    {
        string normalized = rootPath.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);

        string name = Path.GetFileName(normalized);

        if (string.IsNullOrWhiteSpace(name))
        {
            return normalized;
        }

        return name;
    }

    private static void ComputeRepositoryStructuralSignals(RepositoryGraph graph)
    {
        ComputeProjectStructuralSignals(graph);

        var projectTypes =
            graph.Projects
                .Select(p => p.ProjectType ?? "")
                .Where(t => !string.IsNullOrWhiteSpace(t))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();

        var languages =
            graph.Files
                .Where(f => !string.IsNullOrWhiteSpace(f.Language))
                .Select(f => f.Language!)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();

        graph.StructuralSignals =
            new RepositoryStructuralSignals
            {
                IsPolyglotRepository = projectTypes.Count > 1 || languages.Count > 1,
                DistinctProjectTypes = projectTypes.Count,
                DistinctLanguages = languages.Count
            };
    }

    private static void ComputeProjectStructuralSignals(RepositoryGraph graph)
    {
        const int LargeProjectLocThreshold = 5000;
        const double HighDependencyDensityThreshold = 5.0;

        foreach (RepositoryProjectNode project in graph.Projects.OrderBy(p => p.Id, StringComparer.OrdinalIgnoreCase))
        {
            bool legacyDotNet = false;
            bool modernDotNet = false;

            if (!string.IsNullOrWhiteSpace(project.Framework))
            {
                string fw = project.Framework!.ToLowerInvariant();

                if (fw.StartsWith("net4"))
                {
                    legacyDotNet = true;
                }

                if (fw.StartsWith("net6") ||
                    fw.StartsWith("net7") ||
                    fw.StartsWith("net8") ||
                    fw.StartsWith("netcoreapp"))
                {
                    modernDotNet = true;
                }
            }

            bool usesVersionSpecs = project.DependencySummary.VersionSpecCount > 0;

            bool noDeps = project.DependencySummary.TotalDependencyCount == 0;

            bool highDensity =
                project.DependencySummary.DependenciesPerKLoc.HasValue &&
                project.DependencySummary.DependenciesPerKLoc.Value > HighDependencyDensityThreshold;

            bool largeProject = project.Metrics.TotalLinesOfCode >= LargeProjectLocThreshold;

            bool mixedLanguages = project.Metrics.Languages.Count > 1;

            project.StructuralSignals =
                new ProjectStructuralSignals
                {
                    IsLegacyDotNetFramework = legacyDotNet,
                    IsModernDotNet = modernDotNet,
                    UsesVersionSpecs = usesVersionSpecs,
                    HasNoDependencies = noDeps,
                    HighDependencyDensity = highDensity,
                    LargeProject = largeProject,
                    MixedLanguageProject = mixedLanguages
                };
        }
    }

    private static void ComputeRepositoryArchitectureSignals(RepositoryGraph graph)
    {
        ComputeProjectArchitectureSignals(graph);

        var projects = graph.Projects;

        bool hasDocker = projects.Any(p => p.ArchitectureSignals.ContainsDocker);
        bool hasCicd = projects.Any(p => p.ArchitectureSignals.ContainsCICD);
        bool hasInfra = projects.Any(p => p.ArchitectureSignals.ContainsInfrastructureCode);

        int projectsWithTests = projects.Count(p => p.ArchitectureSignals.HasTests);
        int apiProjects = projects.Count(p => p.ArchitectureSignals.IsApiProject);
        int libraryProjects = projects.Count(p => p.ArchitectureSignals.IsLibraryProject);

        var frameworks =
            projects
                .SelectMany(p => p.ArchitectureSignals.TestFrameworks)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(f => f, StringComparer.OrdinalIgnoreCase)
                .ToList();

        graph.ArchitectureSignals =
            new RepositoryArchitectureSignals
            {
                HasDocker = hasDocker,
                HasCICD = hasCicd,
                HasInfrastructureLayer = hasInfra,
                ProjectsWithTestsCount = projectsWithTests,
                ApiProjectCount = apiProjects,
                LibraryProjectCount = libraryProjects,
                DistinctTestFrameworks = frameworks
            };
    }

    private static void ComputeProjectArchitectureSignals(RepositoryGraph graph)
    {
        foreach (var project in graph.Projects.OrderBy(p => p.Id, StringComparer.OrdinalIgnoreCase))
        {
            var projectFiles =
                graph.Files
                    .Where(f => f.ProjectId == project.Id)
                    .ToList();

            int testFileCount = 0;
            var testFrameworks = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (var file in projectFiles)
            {
                string path = file.RelativePath.ToLowerInvariant();

                if (path.Contains("/test") ||
                    path.Contains("/tests") ||
                    path.Contains("__tests__") ||
                    path.EndsWith(".spec.ts") ||
                    path.EndsWith(".spec.js") ||
                    path.EndsWith(".test.ts") ||
                    path.EndsWith(".test.js") ||
                    path.EndsWith("tests.cs") ||
                    path.EndsWith("_test.go") ||
                    path.EndsWith("test.java"))
                {
                    testFileCount++;
                }
            }

            foreach (var dep in project.Dependencies)
            {
                string name = dep.Name.ToLowerInvariant();

                if (name.Contains("xunit")) testFrameworks.Add("xunit");
                if (name.Contains("nunit")) testFrameworks.Add("nunit");
                if (name.Contains("mstest")) testFrameworks.Add("mstest");
                if (name.Contains("jest")) testFrameworks.Add("jest");
                if (name.Contains("mocha")) testFrameworks.Add("mocha");
                if (name.Contains("chai")) testFrameworks.Add("chai");
                if (name.Contains("vitest")) testFrameworks.Add("vitest");
                if (name.Contains("pytest")) testFrameworks.Add("pytest");
                if (name.Contains("junit")) testFrameworks.Add("junit");
                if (name.Contains("mockito")) testFrameworks.Add("mockito");
            }

            bool hasTests = testFileCount > 0 || testFrameworks.Count > 0;

            int nonTestFiles = Math.Max(projectFiles.Count - testFileCount, 1);

            double? ratio = null;

            if (projectFiles.Count > 0)
            {
                ratio = testFileCount / (double)nonTestFiles;
            }

            bool containsDocker =
                projectFiles.Any(f =>
                    f.RelativePath.EndsWith("Dockerfile", StringComparison.OrdinalIgnoreCase));

            bool containsCicd =
                projectFiles.Any(f =>
                    f.RelativePath.EndsWith("azure-pipelines.yml", StringComparison.OrdinalIgnoreCase) ||
                    f.RelativePath.Contains(".github/workflows", StringComparison.OrdinalIgnoreCase));

            bool containsInfra =
                projectFiles.Any(f =>
                    f.Extension?.Equals(".tf", StringComparison.OrdinalIgnoreCase) == true ||
                    f.Extension?.Equals(".bicep", StringComparison.OrdinalIgnoreCase) == true ||
                    f.Extension?.Equals(".yaml", StringComparison.OrdinalIgnoreCase) == true && f.RelativePath.Contains("cloudformation", StringComparison.OrdinalIgnoreCase));

            bool isApi =
                project.Dependencies.Any(d =>
                    d.Name.Contains("aspnet", StringComparison.OrdinalIgnoreCase) ||
                    d.Name.Contains("express", StringComparison.OrdinalIgnoreCase) ||
                    d.Name.Contains("fastapi", StringComparison.OrdinalIgnoreCase));

            bool isLibrary = !isApi;

            project.ArchitectureSignals =
                new ProjectArchitectureSignals
                {
                    HasTests = hasTests,
                    TestFileCount = testFileCount,
                    TestToSourceRatio = ratio,
                    TestFrameworks = testFrameworks.OrderBy(f => f).ToList(),
                    ContainsDocker = containsDocker,
                    ContainsCICD = containsCicd,
                    ContainsInfrastructureCode = containsInfra,
                    IsApiProject = isApi,
                    IsLibraryProject = isLibrary
                };
        }
    }

    private static void ComputeProjectModernizationSignals(RepositoryGraph graph)
    {
        foreach (var project in graph.Projects.OrderBy(p => p.Id, StringComparer.OrdinalIgnoreCase))
        {
            project.ModernizationSignals =
                Modernization.ModernizationSignalBuilder.Build(project);
        }
    }

    private static void ComputeRepositoryModernizationSignals(RepositoryGraph graph)
    {
        graph.ModernizationSignals =
            graph.Projects
                .OrderBy(p => p.Id, StringComparer.OrdinalIgnoreCase)
                .Select(p => p.ModernizationSignals)
                .OrderBy(x => x.FrameworkIdentifier, StringComparer.OrdinalIgnoreCase)
                .ThenBy(x => x.RuntimePlatform.ToString(), StringComparer.OrdinalIgnoreCase)
                .ThenBy(x => x.RuntimeGeneration.ToString(), StringComparer.OrdinalIgnoreCase)
                .ToList();
    }
}

