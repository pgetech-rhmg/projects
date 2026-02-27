using System;

using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Modernization.Classifiers;

public sealed class JavaRuntimeClassifier : IRuntimeClassifier
{
    public bool CanClassify(RepositoryProjectNode project)
    {
        if (project == null)
        {
            return false;
        }

        return string.Equals(project.ProjectType, "java", StringComparison.OrdinalIgnoreCase);
    }

    public ModernizationSignals Classify(RepositoryProjectNode project)
    {
        return new ModernizationSignals(
            RuntimePlatform.Java,
            RuntimeGeneration.JavaModern,
            "java",
            null,
            FrameworkSupportStatus.Unknown);
    }
}

