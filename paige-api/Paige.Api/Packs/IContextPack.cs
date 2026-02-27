namespace Paige.Api.Packs;

public interface IContextPack
{
    ContextPackMetadata Metadata { get; }

    string Prompt { get; }
}

