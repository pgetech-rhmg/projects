using Paige.Api.Engine.RepoAssessment.Model;

namespace Paige.Api.Engine.RepoAssessment.Modernization;

public interface IRuntimeClassifier
{
    bool CanClassify(RepositoryProjectNode project);

    ModernizationSignals Classify(RepositoryProjectNode project);
}

