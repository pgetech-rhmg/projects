namespace Paige.Api.Packs;

public sealed class ContextPackDto
{
    public ContextPackMetadata Metadata { get; set; } = default!;

    public string Prompt { get; set; } = string.Empty;
}

