using Paige.Api.Engine.Common;

namespace Paige.Api.Engine.RepoAssessment;

public sealed record LanguageRule(string Name, IReadOnlyCollection<string> Extensions
);

public sealed record FrameworkRule(string Name, Func<IReadOnlyCollection<ScannedFile>, bool> Detector
);

