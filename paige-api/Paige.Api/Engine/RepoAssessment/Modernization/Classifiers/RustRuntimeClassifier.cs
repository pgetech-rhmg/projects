using System;

using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Modernization.Classifiers;

public sealed class RustRuntimeClassifier : IRuntimeClassifier
{
    public bool CanClassify(RepositoryProjectNode project)
    {
        return string.Equals(project.ProjectType, "rust", StringComparison.OrdinalIgnoreCase);
    }

    public ModernizationSignals Classify(RepositoryProjectNode project)
    {
        return new ModernizationSignals(
            RuntimePlatform.Rust,
            RuntimeGeneration.Unknown,
            "rust",
            null,
            FrameworkSupportStatus.Unknown);
    }
}

