using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Modernization.Classifiers;

public sealed class UnknownRuntimeClassifier : IRuntimeClassifier
{
    public bool CanClassify(RepositoryProjectNode project)
    {
        return true;
    }

    public ModernizationSignals Classify(RepositoryProjectNode project)
    {
        return new ModernizationSignals(
            RuntimePlatform.Unknown,
            RuntimeGeneration.Unknown,
            "unknown",
            null,
            FrameworkSupportStatus.Unknown);
    }
}

