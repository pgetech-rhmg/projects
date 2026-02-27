using System;

using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Modernization.Classifiers;

public sealed class NodeRuntimeClassifier : IRuntimeClassifier
{
    public bool CanClassify(RepositoryProjectNode project)
    {
        if (project == null)
        {
            return false;
        }

        return string.Equals(project.ProjectType, "node", StringComparison.OrdinalIgnoreCase)
               || string.Equals(project.ProjectType, "nodejs", StringComparison.OrdinalIgnoreCase)
               || string.Equals(project.ProjectType, "javascript", StringComparison.OrdinalIgnoreCase)
               || string.Equals(project.ProjectType, "typescript", StringComparison.OrdinalIgnoreCase);
    }

    public ModernizationSignals Classify(RepositoryProjectNode project)
    {
        return new ModernizationSignals(
            RuntimePlatform.Node,
            RuntimeGeneration.NodeLts,
            "node",
            null,
            FrameworkSupportStatus.Unknown);
    }
}

