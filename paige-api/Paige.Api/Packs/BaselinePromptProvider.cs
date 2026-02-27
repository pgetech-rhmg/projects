namespace Paige.Api.Packs;

public sealed class BaselinePromptProvider
{
    public string SystemPrompt { get; }

    public IReadOnlyList<string> PackIds { get; }

    public BaselinePromptProvider(BaselinePackLoader loader)
    {
        var packs = loader.GetBaselinePacks();

        SystemPrompt = string.Join(Environment.NewLine + Environment.NewLine, packs.Select(p => p.Prompt));

        PackIds = packs.Select(p => p.Metadata.PackId).ToList();
    }
}

