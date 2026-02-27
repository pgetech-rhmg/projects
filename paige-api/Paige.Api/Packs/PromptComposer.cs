namespace Paige.Api.Packs;

public sealed class PromptComposer
{
    private readonly BaselinePromptProvider _baseline;

    public PromptComposer(BaselinePromptProvider baseline)
    {
        _baseline = baseline;
    }

    public string ComposeSystemPrompt(IReadOnlyList<IContextPack> dynamicPacks)
    {
        if (dynamicPacks.Count == 0)
        {
            return _baseline.SystemPrompt;
        }

        var dynamicPrompt = string.Join(Environment.NewLine + Environment.NewLine, dynamicPacks.Select(p => p.Prompt));

        return _baseline.SystemPrompt
            + Environment.NewLine
            + Environment.NewLine
            + dynamicPrompt;
    }
}

