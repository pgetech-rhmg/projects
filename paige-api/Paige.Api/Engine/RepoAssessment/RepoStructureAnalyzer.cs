using System.Collections.Immutable;

using Paige.Api.Engine.Common;

namespace Paige.Api.Engine.RepoAssessment;

public sealed class RepoStructureAnalyzer : IRepoStructureAnalyzer
{
    private static readonly HashSet<string> ConfigExtensions =
    [
        ".json", ".yml", ".yaml", ".xml", ".env", ".ini"
    ];

    public RepoStructureSummary Analyze(string repoName, string branch, IReadOnlyCollection<ScannedFile> files)
    {
        var languages = DetectLanguages(files);
        var frameworks = DetectFrameworks(files);
        var keyFiles = DetectKeyArtifacts(files);
        var fileStats = ComputeStats(files);

        return new RepoStructureSummary
        {
            RepoName = repoName,
            Branch = branch,
            Languages = languages,
            Frameworks = frameworks,
            FileStats = fileStats,
            KeyFiles = keyFiles
        };
    }

    private static IReadOnlyCollection<string> DetectLanguages(IReadOnlyCollection<ScannedFile> files)
    {
        var detected = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var rule in RepoDetectionRegistry.Languages)
        {
            if (files.Any(f => rule.Extensions.Any(ext => f.RelativePath.EndsWith(ext, StringComparison.OrdinalIgnoreCase))))
            {
                detected.Add(rule.Name);
            }
        }

        return [.. detected];
    }

    private static IReadOnlyCollection<string> DetectFrameworks(IReadOnlyCollection<ScannedFile> files)
    {
        var detected = new HashSet<string>();

        foreach (var rule in RepoDetectionRegistry.Frameworks)
        {
            if (rule.Detector(files))
            {
                detected.Add(rule.Name);
            }
        }

        return [.. detected];
    }

    private static FileStats ComputeStats(IReadOnlyCollection<ScannedFile> files)
    {
        var byExtension = files
            .GroupBy(f => f.Extension.ToLower())
            .ToDictionary(g => g.Key, g => g.Count(), StringComparer.OrdinalIgnoreCase);

        var byCategory = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
        {
            ["config"] = files.Count(f => ConfigExtensions
                .Any(ext => f.RelativePath.EndsWith(ext, StringComparison.OrdinalIgnoreCase))),

            ["tests"] = files.Count(f =>
                f.RelativePath.Contains("test", StringComparison.OrdinalIgnoreCase)),

            ["docs"] = files.Count(f =>
                f.RelativePath.EndsWith(".md", StringComparison.OrdinalIgnoreCase))
        };

        byCategory["source"] = files.Count - byCategory.Values.Sum();

        return new FileStats
        {
            TotalFiles = files.Count,
            ByExtension = byExtension,
            ByCategory = byCategory
        };
    }

    public static IReadOnlyCollection<EntryPoint> DetectKeyArtifacts(IReadOnlyCollection<ScannedFile> files)
    {
        var detected = new List<EntryPoint>();

        foreach (var entry in RepoDetectionRegistry.Entries)
        {
            if (files.Any(f => Matches(entry, f)))
            {
                detected.Add(entry);
            }
        }

        return [.. detected.OrderByDescending(e => e.Confidence)];
    }

    private static bool Matches(EntryPoint entry, ScannedFile file)
    {
        return entry.MatchType switch
        {
            EntryPointMatchType.FileName =>
                Path.GetFileName(file.RelativePath)
                    .Equals(entry.Match, StringComparison.OrdinalIgnoreCase),

            EntryPointMatchType.FileExtension =>
                file.RelativePath.EndsWith(entry.Match, StringComparison.OrdinalIgnoreCase),

            EntryPointMatchType.PathContains =>
                file.RelativePath.Contains(entry.Match, StringComparison.OrdinalIgnoreCase),

            EntryPointMatchType.ContentContains =>
                file.Content != null && file.Content.Contains(entry.Match, StringComparison.OrdinalIgnoreCase),

            _ => false
        };
    }
}

