using System;

using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Modernization.Classifiers;

public sealed class PythonRuntimeClassifier : IRuntimeClassifier
{
    public bool CanClassify(RepositoryProjectNode project)
    {
        if (project == null)
        {
            return false;
        }

        return string.Equals(project.ProjectType, "python", StringComparison.OrdinalIgnoreCase);
    }

    public ModernizationSignals Classify(RepositoryProjectNode project)
    {
        return new ModernizationSignals(
            RuntimePlatform.Python,
            RuntimeGeneration.Python3,
            "python",
            null,
            FrameworkSupportStatus.Unknown);
    }
}

