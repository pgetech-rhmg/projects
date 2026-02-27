using System;
using System.Collections.Generic;

using Paige.Api.Packs;

using Xunit;

namespace Paige.Api.UnitTests.Packs;

public sealed class PromptComposerTests
{
    private sealed class FakeContextPack : IContextPack
    {
        public FakeContextPack(ContextPackMetadata metadata, string prompt)
        {
            Metadata = metadata;
            Prompt = prompt;
        }

        public ContextPackMetadata Metadata { get; }

        public string Prompt { get; }
    }

    // -------------------------------------------------------------------------
    // No dynamic packs
    // -------------------------------------------------------------------------

    [Fact]
    public void ComposeSystemPrompt_Should_Return_Baseline_When_No_Dynamic_Packs()
    {
        // Arrange
        var baselineProvider = CreateBaselineProvider("BASELINE_PROMPT");
        var composer = new PromptComposer(baselineProvider);

        // Act
        var result = composer.ComposeSystemPrompt(Array.Empty<IContextPack>());

        // Assert
        Assert.Equal(baselineProvider.SystemPrompt, result);
    }

    // -------------------------------------------------------------------------
    // Single dynamic pack
    // -------------------------------------------------------------------------

    [Fact]
    public void ComposeSystemPrompt_Should_Append_Single_Dynamic_Pack()
    {
        // Arrange
        var baselineProvider = CreateBaselineProvider("BASELINE_PROMPT");
        var composer = new PromptComposer(baselineProvider);

        var dynamicPacks = new List<IContextPack>
        {
            CreateDynamicPack("DYNAMIC_1")
        };

        // Act
        var result = composer.ComposeSystemPrompt(dynamicPacks);

        // Assert
        var expected =
            baselineProvider.SystemPrompt
            + Environment.NewLine
            + Environment.NewLine
            + "DYNAMIC_1";

        Assert.Equal(expected, result);
    }

    // -------------------------------------------------------------------------
    // Multiple dynamic packs
    // -------------------------------------------------------------------------

    [Fact]
    public void ComposeSystemPrompt_Should_Append_Multiple_Dynamic_Packs_In_Order()
    {
        // Arrange
        var baselineProvider = CreateBaselineProvider("BASELINE_PROMPT");
        var composer = new PromptComposer(baselineProvider);

        var dynamicPacks = new List<IContextPack>
        {
            CreateDynamicPack("DYNAMIC_1"),
            CreateDynamicPack("DYNAMIC_2")
        };

        // Act
        var result = composer.ComposeSystemPrompt(dynamicPacks);

        // Assert
        var expected =
            baselineProvider.SystemPrompt
            + Environment.NewLine
            + Environment.NewLine
            + "DYNAMIC_1"
            + Environment.NewLine
            + Environment.NewLine
            + "DYNAMIC_2";

        Assert.Equal(expected, result);
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private static BaselinePromptProvider CreateBaselineProvider(string baselinePrompt)
    {
        // BaselinePromptProvider builds SystemPrompt from baseline packs (AlwaysInject=true)
        var packs = new List<IContextPack>
        {
            new FakeContextPack(
                new ContextPackMetadata
                {
                    PackId = "baseline-pack",
                    Name = "baseline",
                    Version = "1.0",
                    Description = "baseline",
                    AlwaysInject = true,

                    // Needed because BaselinePackLoader sorts on these
                    SafetyCritical = false,
                    Priority = 0
                },
                baselinePrompt)
        };

        var loader = new BaselinePackLoader(packs);
        return new BaselinePromptProvider(loader);
    }

    private static IContextPack CreateDynamicPack(string prompt)
    {
        return new FakeContextPack(
            new ContextPackMetadata
            {
                PackId = Guid.NewGuid().ToString("N"),
                Name = "dynamic",
                Version = "1.0",
                Description = "dynamic",
                AlwaysInject = false,
                SafetyCritical = false,
                Priority = 0
            },
            prompt);
    }
}

