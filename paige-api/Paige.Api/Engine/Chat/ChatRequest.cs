namespace Paige.Api.Engine.Chat;

public sealed class ChatRequest
{
    public string Prompt { get; set; } = null!;

    public IReadOnlyList<ChatMessage> History { get; set; } = [];
}

public sealed class ChatMessage
{
    public string Role { get; set; } = null!;

    public string Content { get; set; } = null!;
}

