namespace Paige.Api.Packs;

public sealed class PackClassificationResult
{
    public string[] Domains { get; init; } = [];

    public string[] Topics { get; init; } = [];

    public string RiskLevel { get; init; } = "medium";

    public bool RequiresGovernance { get; init; }

    public string[] IntentHints { get; init; } = [];
}

