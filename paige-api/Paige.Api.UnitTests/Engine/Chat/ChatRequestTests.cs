using Xunit;

using Paige.Api.Engine.Chat;

namespace Paige.Api.Tests.Engine.Chat;

public sealed class ChatRequestTests
{
    // ============================================================
    // Default values
    // ============================================================

    [Fact]
    public void ChatRequest_DefaultValues_AreCorrect()
    {
        var request = new ChatRequest();

        Assert.Null(request.Prompt);
        Assert.NotNull(request.History);
        Assert.Empty(request.History);
    }

    // ============================================================
    // Property assignment
    // ============================================================

    [Fact]
    public void ChatRequest_AllowsSettingProperties()
    {
        var history = new List<ChatMessage>
        {
            new ChatMessage
            {
                Role = "user",
                Content = "hello"
            }
        };

        var request = new ChatRequest
        {
            Prompt = "test",
            History = history
        };

        Assert.Equal("test", request.Prompt);
        Assert.Single(request.History);
        Assert.Equal("user", request.History[0].Role);
        Assert.Equal("hello", request.History[0].Content);
    }

    // ============================================================
    // ChatMessage default + assignment
    // ============================================================

    [Fact]
    public void ChatMessage_DefaultAndSetters_Work()
    {
        var message = new ChatMessage();

        Assert.Null(message.Role);
        Assert.Null(message.Content);

        message.Role = "assistant";
        message.Content = "response";

        Assert.Equal("assistant", message.Role);
        Assert.Equal("response", message.Content);
    }
}

