namespace Paige.Api.Engine.RepoAssessment.Model;

public sealed class ModernizationSignals
{
    public RuntimePlatform RuntimePlatform { get; }
    public RuntimeGeneration RuntimeGeneration { get; }
    public string FrameworkIdentifier { get; }
    public string? FrameworkVersion { get; }
    public FrameworkSupportStatus SupportStatus { get; }

    public ModernizationSignals(
        RuntimePlatform runtimePlatform,
        RuntimeGeneration runtimeGeneration,
        string frameworkIdentifier,
        string? frameworkVersion,
        FrameworkSupportStatus supportStatus)
    {
        RuntimePlatform = runtimePlatform;
        RuntimeGeneration = runtimeGeneration;
        FrameworkIdentifier = frameworkIdentifier;
        FrameworkVersion = frameworkVersion;
        SupportStatus = supportStatus;
    }
}

