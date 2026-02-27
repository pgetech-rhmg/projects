using System;
using System.Collections.Generic;

using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Modernization.Classifiers;

public sealed class DotNetRuntimeClassifier : IRuntimeClassifier
{
    private static readonly Dictionary<string, FrameworkSupportStatus> SupportTable =
        new(StringComparer.OrdinalIgnoreCase)
        {
            { "net472", FrameworkSupportStatus.Eol },
            { "net48", FrameworkSupportStatus.NearEol },

            { "netcoreapp3.1", FrameworkSupportStatus.Eol },

            { "net5.0", FrameworkSupportStatus.Eol },

            { "net6.0", FrameworkSupportStatus.Supported },
            { "net7.0", FrameworkSupportStatus.Supported },
            { "net8.0", FrameworkSupportStatus.Supported },
            { "net9.0", FrameworkSupportStatus.Supported },
            { "net10.0", FrameworkSupportStatus.Supported }
        };

    public bool CanClassify(RepositoryProjectNode project)
    {
        if (project == null)
        {
            return false;
        }

        if (!string.IsNullOrWhiteSpace(project.Framework) &&
            project.Framework.StartsWith("net", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        return string.Equals(project.ProjectType, "dotnet", StringComparison.OrdinalIgnoreCase)
               || string.Equals(project.ProjectType, ".net", StringComparison.OrdinalIgnoreCase)
               || string.Equals(project.ProjectType, "csharp", StringComparison.OrdinalIgnoreCase);
    }

    public ModernizationSignals Classify(RepositoryProjectNode project)
    {
        string framework = (project.Framework ?? string.Empty).Trim();

        FrameworkSupportStatus support =
            SupportTable.TryGetValue(framework, out FrameworkSupportStatus status)
                ? status
                : FrameworkSupportStatus.Unknown;

        RuntimeGeneration generation =
            framework.StartsWith("net4", StringComparison.OrdinalIgnoreCase)
                ? RuntimeGeneration.DotNetFramework
                : framework.StartsWith("netcore", StringComparison.OrdinalIgnoreCase)
                    ? RuntimeGeneration.DotNetCore
                    : framework.StartsWith("net", StringComparison.OrdinalIgnoreCase)
                        ? RuntimeGeneration.DotNetModern
                        : RuntimeGeneration.Unknown;

        string frameworkIdentifier = framework.Length == 0 ? "dotnet" : framework;
        string? frameworkVersion = framework.Length == 0 ? null : framework;

        return new ModernizationSignals(
            RuntimePlatform.DotNet,
            generation,
            frameworkIdentifier,
            frameworkVersion,
            support);
    }
}

