using System;

using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Modernization.Classifiers;

public sealed class RubyRuntimeClassifier : IRuntimeClassifier
{
    public bool CanClassify(RepositoryProjectNode project)
    {
        return string.Equals(project.ProjectType, "ruby", StringComparison.OrdinalIgnoreCase);
    }

    public ModernizationSignals Classify(RepositoryProjectNode project)
    {
        return new ModernizationSignals(
            RuntimePlatform.Ruby,
            RuntimeGeneration.Unknown,
            "ruby",
            null,
            FrameworkSupportStatus.Unknown);
    }
}

