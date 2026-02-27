namespace Paige.Api.Packs;

public sealed class PackScore
{
    public required IContextPack Pack { get; init; }
    public int Score { get; init; }
}

