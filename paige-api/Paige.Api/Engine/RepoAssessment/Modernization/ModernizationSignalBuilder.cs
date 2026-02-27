using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Modernization;

public static class ModernizationSignalBuilder
{
    public static ModernizationSignals Build(RepositoryProjectNode project)
    {
        var classifier = RuntimeClassifierRegistry.GetClassifier(project);

        return classifier.Classify(project);
    }
}

