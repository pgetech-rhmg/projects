namespace Paige.Api.Engine.PortKey;

public sealed class PortKeyPromptEnvelope
{
    public required IReadOnlyList<object> Messages { get; init; }

    public string? Model { get; init; }

    public string? PromptKey { get; init; }
}

