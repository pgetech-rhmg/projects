using System;
using System.Collections.Generic;
using System.Linq;

using Paige.Api.Engine.Common;
using Paige.Api.Engine.RepoAssessment;

using Xunit;

namespace Paige.Api.Tests.Engine.RepoAssessment;

public sealed class RepoStructureAnalyzerTests
{
    private readonly RepoStructureAnalyzer _analyzer = new();

    // -------------------------------------------------------------------------
    // Analyze (integration of all private methods)
    // -------------------------------------------------------------------------

    [Fact]
    public void Analyze_Should_Detect_Languages_Frameworks_Stats_And_KeyFiles()
    {
        var files = new List<ScannedFile>
        {
            CreateFile("Program.cs", "var builder = WebApplication.CreateBuilder(args);"),
            CreateFile("angular.json", ""),
            CreateFile("app.ts", "console.log('ts');"),
            CreateFile("main.py", "if __name__ == '__main__': print('x')"),
            CreateFile("README.md", "docs"),
            CreateFile("config.yaml", "setting: value"),
            CreateFile("unit-test.cs", "test content"),
            CreateFile("Dockerfile", "ENTRYPOINT dotnet app.dll")
        };

        var result = _analyzer.Analyze("repo", "main", files);

        Assert.Equal("repo", result.RepoName);
        Assert.Equal("main", result.Branch);

        // Languages
        Assert.Contains("C#", result.Languages);
        Assert.Contains("TypeScript", result.Languages);
        Assert.Contains("Python", result.Languages);

        // Frameworks
        Assert.Contains("ASP.NET Core", result.Frameworks);
        Assert.Contains("Angular", result.Frameworks);

        // Stats
        Assert.Equal(files.Count, result.FileStats.TotalFiles);
        Assert.True(result.FileStats.ByExtension.ContainsKey(".cs"));
        Assert.True(result.FileStats.ByCategory["docs"] > 0);
        Assert.True(result.FileStats.ByCategory["config"] > 0);
        Assert.True(result.FileStats.ByCategory["tests"] > 0);
        Assert.True(result.FileStats.ByCategory["source"] >= 0);

        // Key Artifacts (confidence ordered)
        Assert.NotEmpty(result.KeyFiles);
        Assert.True(result.KeyFiles.SequenceEqual(
            result.KeyFiles.OrderByDescending(e => e.Confidence)));
    }

    // -------------------------------------------------------------------------
    // ComputeStats edge case (no files)
    // -------------------------------------------------------------------------

    [Fact]
    public void Analyze_Should_Handle_Empty_File_List()
    {
        var result = _analyzer.Analyze("repo", "main", Array.Empty<ScannedFile>());

        Assert.Empty(result.Languages);
        Assert.Empty(result.Frameworks);
        Assert.Empty(result.KeyFiles);
        Assert.Equal(0, result.FileStats.TotalFiles);
        Assert.Equal(0, result.FileStats.ByCategory["config"]);
        Assert.Equal(0, result.FileStats.ByCategory["tests"]);
        Assert.Equal(0, result.FileStats.ByCategory["docs"]);
        Assert.Equal(0, result.FileStats.ByCategory["source"]);
    }

    // -------------------------------------------------------------------------
    // DetectKeyArtifacts - explicit match types
    // -------------------------------------------------------------------------

    [Fact]
    public void DetectKeyArtifacts_Should_Match_FileName()
    {
        var files = new[]
        {
            CreateFile("Program.cs", "")
        };

        var results = RepoStructureAnalyzer.DetectKeyArtifacts(files);

        Assert.Contains(results, e => e.Match == "Program.cs");
    }

    [Fact]
    public void DetectKeyArtifacts_Should_Match_FileExtension()
    {
        var entry = new EntryPoint(
            "Test Extension",
            ".xyz",
            EntryPointMatchType.FileExtension,
            "Test",
            1);

        var files = new[]
        {
            CreateFile("file.xyz", "")
        };

        var results = InvokeMatches(entry, files);

        Assert.True(results);
    }

    [Fact]
    public void DetectKeyArtifacts_Should_Match_PathContains()
    {
        var entry = new EntryPoint(
            "Test Path",
            "folder",
            EntryPointMatchType.PathContains,
            "Test",
            1);

        var files = new[]
        {
            CreateFile("folder/file.txt", "")
        };

        var results = InvokeMatches(entry, files);

        Assert.True(results);
    }

    [Fact]
    public void DetectKeyArtifacts_Should_Match_ContentContains()
    {
        var entry = new EntryPoint(
            "Test Content",
            "needle",
            EntryPointMatchType.ContentContains,
            "Test",
            1);

        var files = new[]
        {
            CreateFile("file.txt", "haystack needle here")
        };

        var results = InvokeMatches(entry, files);

        Assert.True(results);
    }

    [Fact]
    public void DetectKeyArtifacts_Should_Return_False_For_Unknown_MatchType()
    {
        var entry = new EntryPoint(
            "Invalid",
            "x",
            (EntryPointMatchType)999,
            "Test",
            1);

        var files = new[]
        {
            CreateFile("file.txt", "x")
        };

        var result = InvokeMatches(entry, files);

        Assert.False(result);
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private static bool InvokeMatches(EntryPoint entry, IReadOnlyCollection<ScannedFile> files)
    {
        return files.Any(f =>
        {
            var method = typeof(RepoStructureAnalyzer)
                .GetMethod("Matches", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static)!;

            return (bool)method.Invoke(null, new object[] { entry, f })!;
        });
    }

    private static ScannedFile CreateFile(string relativePath, string content)
    {
        return new ScannedFile
        {
            RelativePath = relativePath,
            FullPath = $"/tmp/{relativePath.Replace('\\', '/')}",
            Content = content
        };
    }
}

