namespace Paige.Api.Packs;

public sealed class ContextPackMetadata
{
    public string PackId { get; init; } = default!;

    public string Name { get; init; } = default!;

    public string Version { get; init; } = default!;

    public string Description { get; init; } = default!;

    public string[] Domains { get; init; } = [];

    public string[] Topics { get; init; } = [];

    public string[] Audience { get; init; } = [];

    public string RiskLevel { get; init; } = "medium"; // low | medium | high

    public int Priority { get; init; }

    public string[] Keywords { get; init; } = [];

    public string[] ConflictsWith { get; init; } = [];

    public bool AlwaysInject { get; init; }

    public bool SafetyCritical { get; init; }
}

