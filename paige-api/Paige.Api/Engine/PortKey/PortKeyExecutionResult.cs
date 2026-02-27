namespace Paige.Api.Engine.PortKey;

public sealed class PortKeyExecutionResult
{
    public string Output { get; set; } = null!;

    public string ModelAlias { get; set; } = null!;

    public int InputTokens { get; set; }

    public int OutputTokens { get; set; }
}
