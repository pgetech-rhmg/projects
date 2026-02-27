using System.Collections.Generic;

using Paige.Api.Engine.RepoAssessment.Model;
using Paige.Api.Engine.RepoAssessment.Modernization.Classifiers;

namespace Paige.Api.Engine.RepoAssessment.Modernization;

public static class RuntimeClassifierRegistry
{
    private static readonly IReadOnlyList<IRuntimeClassifier> Classifiers =
        new IRuntimeClassifier[]
        {
            new DotNetRuntimeClassifier(),
            new NodeRuntimeClassifier(),
            new PythonRuntimeClassifier(),
            new JavaRuntimeClassifier(),
            new GoRuntimeClassifier(),
            new RustRuntimeClassifier(),
            new RubyRuntimeClassifier(),
            new PhpRuntimeClassifier(),
            new TerraformRuntimeClassifier(),
            new UnknownRuntimeClassifier()
        };

    public static IRuntimeClassifier GetClassifier(RepositoryProjectNode project)
    {
        foreach (IRuntimeClassifier classifier in Classifiers)
        {
            if (classifier.CanClassify(project))
            {
                return classifier;
            }
        }

        return new UnknownRuntimeClassifier();
    }
}

