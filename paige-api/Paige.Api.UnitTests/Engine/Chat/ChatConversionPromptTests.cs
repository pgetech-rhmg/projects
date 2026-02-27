using System;
using System.Collections.Generic;
using System.Linq;

using Paige.Api.Engine.Chat;
using Paige.Api.Engine.PortKey;

using Xunit;

namespace Paige.Api.UnitTests.Engine.Chat;

public sealed class ChatConversionPromptTests
{
    // -------------------------------------------------------------------------
    // Full injection path
    // -------------------------------------------------------------------------

    [Fact]
    public void BuildPrompt_Should_Include_All_Sections_In_Order()
    {
        var request = new ChatRequest
        {
            Prompt = "User prompt",
            History = new List<ChatMessage>
            {
                new ChatMessage { Role = "assistant", Content = "Previous reply" },
                new ChatMessage { Role = "user", Content = "Previous question" }
            }
        };

        var envelope = ChatConversionPrompt.BuildPrompt(
            baselinePrompt: "BASELINE",
            contextPrompt: "CONTEXT",
            request: request);

        Assert.Equal("chat-default", envelope.PromptKey);

        var messages = envelope.Messages.ToList();

        // Expected order:
        // 0 - system (SystemPrompt)
        // 1 - system (baseline)
        // 2 - system (context)
        // 3 - history[0]
        // 4 - history[1]
        // 5 - user prompt

        Assert.Equal(6, messages.Count);

        Assert.Equal("system", GetRole(messages[0]));
        Assert.Equal(ChatConversionPrompt.SystemPrompt, GetContent(messages[0]));

        Assert.Equal("system", GetRole(messages[1]));
        Assert.Equal("BASELINE", GetContent(messages[1]));

        Assert.Equal("system", GetRole(messages[2]));
        Assert.Equal("CONTEXT", GetContent(messages[2]));

        Assert.Equal("assistant", GetRole(messages[3]));
        Assert.Equal("Previous reply", GetContent(messages[3]));

        Assert.Equal("user", GetRole(messages[4]));
        Assert.Equal("Previous question", GetContent(messages[4]));

        Assert.Equal("user", GetRole(messages[5]));
        Assert.Equal("User prompt", GetContent(messages[5]));
    }

    // -------------------------------------------------------------------------
    // No baseline / no context
    // -------------------------------------------------------------------------

    [Fact]
    public void BuildPrompt_Should_Skip_Empty_Baseline_And_Context()
    {
        var request = new ChatRequest
        {
            Prompt = "User prompt",
            History = new List<ChatMessage>()
        };

        var envelope = ChatConversionPrompt.BuildPrompt(
            baselinePrompt: "",
            contextPrompt: "",
            request: request);

        var messages = envelope.Messages.ToList();

        // Only:
        // 0 - SystemPrompt
        // 1 - user prompt

        Assert.Equal(2, messages.Count);

        Assert.Equal("system", GetRole(messages[0]));
        Assert.Equal(ChatConversionPrompt.SystemPrompt, GetContent(messages[0]));

        Assert.Equal("user", GetRole(messages[1]));
        Assert.Equal("User prompt", GetContent(messages[1]));
    }

    // -------------------------------------------------------------------------
    // Baseline only
    // -------------------------------------------------------------------------

    [Fact]
    public void BuildPrompt_Should_Include_Baseline_Only()
    {
        var request = new ChatRequest
        {
            Prompt = "User prompt",
            History = new List<ChatMessage>()
        };

        var envelope = ChatConversionPrompt.BuildPrompt(
            baselinePrompt: "BASELINE",
            contextPrompt: null!,
            request: request);

        var messages = envelope.Messages.ToList();

        Assert.Equal(3, messages.Count);

        Assert.Equal("system", GetRole(messages[1]));
        Assert.Equal("BASELINE", GetContent(messages[1]));
    }

    // -------------------------------------------------------------------------
    // Context only
    // -------------------------------------------------------------------------

    [Fact]
    public void BuildPrompt_Should_Include_Context_Only()
    {
        var request = new ChatRequest
        {
            Prompt = "User prompt",
            History = new List<ChatMessage>()
        };

        var envelope = ChatConversionPrompt.BuildPrompt(
            baselinePrompt: null!,
            contextPrompt: "CONTEXT",
            request: request);

        var messages = envelope.Messages.ToList();

        Assert.Equal(3, messages.Count);

        Assert.Equal("system", GetRole(messages[1]));
        Assert.Equal("CONTEXT", GetContent(messages[1]));
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private static string GetRole(object message)
    {
        return (string)message
            .GetType()
            .GetProperty("role")!
            .GetValue(message)!;
    }

    private static string GetContent(object message)
    {
        return (string)message
            .GetType()
            .GetProperty("content")!
            .GetValue(message)!;
    }
}

