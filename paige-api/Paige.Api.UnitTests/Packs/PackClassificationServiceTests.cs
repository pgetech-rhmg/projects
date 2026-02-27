using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.Extensions.Options;

using Moq;

using Paige.Api.Engine.Common;
using Paige.Api.Engine.PortKey;
using Paige.Api.Packs;

using Xunit;

namespace Paige.Api.UnitTests.Packs;

public sealed class PackClassificationServiceTests
{
    private sealed class FakeContextPack : IContextPack
    {
        public FakeContextPack(ContextPackMetadata metadata)
        {
            Metadata = metadata;
        }

        public ContextPackMetadata Metadata { get; }

        public string Prompt => "ignored";
    }

    // -------------------------------------------------------------------------
    // Success path
    // -------------------------------------------------------------------------

    [Fact]
    public async Task ClassifyAsync_Should_Aggregate_Domains_Topics_And_Return_Result()
    {
        // Arrange
        var config = new Config
        {
            PortKeyClassifierModel = "cheap-model"
        };

        var packs = new List<IContextPack>
        {
            new FakeContextPack(new ContextPackMetadata
            {
                Domains = new[] { "cloud", "security", "" },
                Topics = new[] { "iam", "auth" }
            }),
            new FakeContextPack(new ContextPackMetadata
            {
                Domains = new[] { "Cloud" }, // duplicate (case-insensitive)
                Topics = new[] { "auth", "deployment" }
            })
        };

        var expectedResult = new PackClassificationResult
        {
            Domains = new[] { "cloud" },
            Topics = new[] { "iam" },
            RiskLevel = "low",
            RequiresGovernance = false,
            IntentHints = new[] { "how-to" }
        };

        var portKeyMock = new Mock<IPortKeyExecutionService>();

        portKeyMock
            .Setup(x => x.ExecuteAsync(
                It.IsAny<PortKeyPromptEnvelope>(),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PortKeyExecutionResult
            {
                Output = JsonSerializer.Serialize(expectedResult)
            });

        var service = new PackClassificationService(
            Options.Create(config),
            portKeyMock.Object,
            packs);

        // Act
        var result = await service.ClassifyAsync("test prompt", CancellationToken.None);

        // Assert
        Assert.Equal("low", result.RiskLevel);
        Assert.Contains("cloud", result.Domains);
        Assert.Contains("iam", result.Topics);

        portKeyMock.Verify(x =>
            x.ExecuteAsync(
                It.Is<PortKeyPromptEnvelope>(e =>
                    e.Model == "cheap-model"
                    && e.PromptKey == "classifier"
                    && e.Messages.Count == 2),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // -------------------------------------------------------------------------
    // Invalid JSON path
    // -------------------------------------------------------------------------

    [Fact]
    public async Task ClassifyAsync_Should_Throw_When_Invalid_Json()
    {
        var config = new Config
        {
            PortKeyClassifierModel = "cheap-model"
        };

        var packs = new List<IContextPack>();

        var portKeyMock = new Mock<IPortKeyExecutionService>();

        portKeyMock
            .Setup(x => x.ExecuteAsync(
                It.IsAny<PortKeyPromptEnvelope>(),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PortKeyExecutionResult
            {
                Output = "NOT VALID JSON"
            });

        var service = new PackClassificationService(
            Options.Create(config),
            portKeyMock.Object,
            packs);

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            service.ClassifyAsync("test", CancellationToken.None));
    }

    // -------------------------------------------------------------------------
    // FormatList empty branch (via no domains/topics)
    // -------------------------------------------------------------------------

    [Fact]
    public async Task ClassifyAsync_Should_Handle_No_Domains_Or_Topics()
    {
        var config = new Config
        {
            PortKeyClassifierModel = "cheap-model"
        };

        var packs = new List<IContextPack>
        {
            new FakeContextPack(new ContextPackMetadata())
        };

        var expectedResult = new PackClassificationResult
        {
            Domains = Array.Empty<string>(),
            Topics = Array.Empty<string>(),
            RiskLevel = "low",
            RequiresGovernance = false,
            IntentHints = Array.Empty<string>()
        };

        var portKeyMock = new Mock<IPortKeyExecutionService>();

        portKeyMock
            .Setup(x => x.ExecuteAsync(
                It.IsAny<PortKeyPromptEnvelope>(),
                It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PortKeyExecutionResult
            {
                Output = JsonSerializer.Serialize(expectedResult)
            });

        var service = new PackClassificationService(
            Options.Create(config),
            portKeyMock.Object,
            packs);

        var result = await service.ClassifyAsync("anything", CancellationToken.None);

        Assert.NotNull(result);
    }
}

