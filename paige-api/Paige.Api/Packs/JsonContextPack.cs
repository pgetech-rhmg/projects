namespace Paige.Api.Packs;

public sealed class JsonContextPack : IContextPack
{
    public ContextPackMetadata Metadata { get; }

    public string Prompt { get; }

    public JsonContextPack(
        ContextPackMetadata metadata,
        string prompt)
    {
        Metadata = metadata;
        Prompt = prompt;
    }
}

