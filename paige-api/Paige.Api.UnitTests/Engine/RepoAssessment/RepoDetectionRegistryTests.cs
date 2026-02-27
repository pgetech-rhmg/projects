using System;
using System.Collections.Generic;
using System.Linq;

using Paige.Api.Engine.Common;
using Paige.Api.Engine.RepoAssessment;

using Xunit;

namespace Paige.Api.Tests.Engine.RepoAssessment;

public sealed class RepoDetectionRegistryTests
{
    // -------------------------------------------------------------------------
    // Languages
    // -------------------------------------------------------------------------

    [Fact]
    public void Languages_Should_Be_Populated_And_Contain_Known_Rules()
    {
        var languages = RepoDetectionRegistry.Languages;

        Assert.NotNull(languages);
        Assert.NotEmpty(languages);

        Assert.Contains(languages, l => l.Name == "C#" && l.Extensions.Contains(".cs"));
        Assert.Contains(languages, l => l.Name == "TypeScript" && l.Extensions.Contains(".ts"));
        Assert.Contains(languages, l => l.Name == "Python" && l.Extensions.Contains(".py"));
        Assert.Contains(languages, l => l.Name == "HCL" && l.Extensions.Contains(".tf"));
    }

    // -------------------------------------------------------------------------
    // Frameworks
    // -------------------------------------------------------------------------

    [Theory]
    [MemberData(nameof(GetFrameworkTrueCases))]
    public void Frameworks_Should_Detect_When_Matching(string frameworkName, IReadOnlyCollection<ScannedFile> files)
    {
        var rule = RepoDetectionRegistry.Frameworks.Single(f => f.Name == frameworkName);

        var result = rule.Detector(files);

        Assert.True(result);
    }

    [Theory]
    [MemberData(nameof(GetFrameworkFalseCases))]
    public void Frameworks_Should_Not_Detect_When_Not_Matching(string frameworkName, IReadOnlyCollection<ScannedFile> files)
    {
        var rule = RepoDetectionRegistry.Frameworks.Single(f => f.Name == frameworkName);

        var result = rule.Detector(files);

        Assert.False(result);
    }

    public static IEnumerable<object[]> GetFrameworkTrueCases()
    {
        yield return new object[]
        {
            "ASP.NET Core",
            new[]
            {
                CreateFile("Program.cs", "var builder = WebApplication.CreateBuilder(args);")
            }
        };

        yield return new object[]
        {
            "ASP.NET MVC",
            new[]
            {
                CreateFile("Controllers/HomeController.cs", "public sealed class HomeController : Controller { }")
            }
        };

        yield return new object[]
        {
            "Spring Boot",
            new[]
            {
                CreateFile("App.java", "@SpringBootApplication")
            }
        };

        yield return new object[]
        {
            "Spring MVC",
            new[]
            {
                CreateFile("Controller.java", "@RestController")
            }
        };

        yield return new object[]
        {
            "Quarkus",
            new[]
            {
                CreateFile("App.java", "import io.quarkus.runtime.Quarkus;")
            }
        };

        yield return new object[]
        {
            "Micronaut",
            new[]
            {
                CreateFile("App.java", "import io.micronaut.runtime.Micronaut;")
            }
        };

        // Angular has OR: angular.json OR content contains @angular/core
        yield return new object[]
        {
            "Angular",
            new[]
            {
                CreateFile("angular.json", "")
            }
        };

        yield return new object[]
        {
            "React",
            new[]
            {
                CreateFile("App.tsx", "import React from 'react';")
            }
        };

        yield return new object[]
        {
            "Vue",
            new[]
            {
                CreateFile("App.vue", "<template></template>")
            }
        };

        yield return new object[]
        {
            "Next.js",
            new[]
            {
                CreateFile("next.config.js", "module.exports = {};")
            }
        };

        yield return new object[]
        {
            "Svelte",
            new[]
            {
                CreateFile("App.svelte", "<script></script>")
            }
        };

        yield return new object[]
        {
            "Django",
            new[]
            {
                CreateFile("manage.py", "print('hello')")
            }
        };

        yield return new object[]
        {
            "FastAPI",
            new[]
            {
                CreateFile("main.py", "app = FastAPI()")
            }
        };

        yield return new object[]
        {
            "Flask",
            new[]
            {
                CreateFile("app.py", "app = Flask(__name__)")
            }
        };

        yield return new object[]
        {
            "MuleSoft",
            new[]
            {
                CreateFile("mule.xml", "www.mulesoft.org/schema/mule")
            }
        };

        yield return new object[]
        {
            "Terraform",
            new[]
            {
                CreateFile("main.tf", "")
            }
        };

        yield return new object[]
        {
            "CloudFormation",
            new[]
            {
                CreateFile("template.yml", "AWSTemplateFormatVersion: '2010-09-09'")
            }
        };

        yield return new object[]
        {
            "Maven",
            new[]
            {
                CreateFile("pom.xml", "<project></project>")
            }
        };

        yield return new object[]
        {
            "Gradle",
            new[]
            {
                CreateFile("build.gradle.kts", "plugins { }")
            }
        };

        yield return new object[]
        {
            "Node.js",
            new[]
            {
                CreateFile("package.json", "{ }")
            }
        };
    }

    public static IEnumerable<object[]> GetFrameworkFalseCases()
    {
        // Provide at least 1 file with non-null Content to safely exercise all detectors that do f.Content!
        var nonMatchFiles = new[]
        {
            CreateFile("README.md", "nothing-to-see-here")
        };

        foreach (var framework in RepoDetectionRegistry.Frameworks)
        {
            yield return new object[] { framework.Name, nonMatchFiles };
        }
    }

    // -------------------------------------------------------------------------
    // Entries
    // -------------------------------------------------------------------------

    [Fact]
    public void Entries_Should_Be_Populated_And_Contain_Representative_Items()
    {
        var entries = RepoDetectionRegistry.Entries;

        Assert.NotNull(entries);
        Assert.NotEmpty(entries);

        var aspNetCoreEntry = entries.Single(e => e.Name == "ASP.NET Core Entry");
        Assert.Equal("Program.cs", aspNetCoreEntry.Match);
        Assert.Equal(EntryPointMatchType.FileName, aspNetCoreEntry.MatchType);
        Assert.Equal("Backend", aspNetCoreEntry.Category);
        Assert.Equal(5, aspNetCoreEntry.Confidence);

        var htmlEntry = entries.Single(e => e.Name == "HTML Entry");
        Assert.Equal("index.html", htmlEntry.Match);
        Assert.Equal(EntryPointMatchType.FileName, htmlEntry.MatchType);
        Assert.Equal("Frontend", htmlEntry.Category);

        var dockerEntry = entries.Single(e => e.Name == "Docker Entrypoint");
        Assert.Equal("ENTRYPOINT", dockerEntry.Match);
        Assert.Equal(EntryPointMatchType.ContentContains, dockerEntry.MatchType);
        Assert.Equal("Container", dockerEntry.Category);
        Assert.Equal(4, dockerEntry.Confidence);
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

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

