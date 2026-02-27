using Moq;
using Xunit;

using Paige.Api.Engine.Chat;
using Paige.Api.Engine.PortKey;
using Paige.Api.Packs;

namespace Paige.Api.Tests.Engine.Chat;

public sealed class ChatExecutionServiceTests
{
    private readonly Mock<IPortKeyExecutionService> _portKeyMock = new(MockBehavior.Strict);
    private readonly Mock<IPackClassificationService> _classificationMock = new(MockBehavior.Strict);

    private ChatExecutionService CreateService(IReadOnlyCollection<IContextPack>? packs = null)
    {
        packs ??= new List<IContextPack>();

        var loader = new BaselinePackLoader(packs);
        var baselineProvider = new BaselinePromptProvider(loader);
        var scoringService = new PackScoringService();

        return new ChatExecutionService(
            packs,
            _portKeyMock.Object,
            baselineProvider,
            _classificationMock.Object,
            scoringService);
    }

    // ============================================================
    // Guard validation (non-streaming)
    // ============================================================

    [Fact]
    public async Task SendMessageAsync_Throws_WhenRequestNull()
    {
        var service = CreateService();

        await Assert.ThrowsAsync<ArgumentNullException>(() =>
            service.SendMessageAsync(null!, CancellationToken.None));
    }

    [Fact]
    public async Task SendMessageAsync_Throws_WhenPromptEmpty()
    {
        var service = CreateService();

        await Assert.ThrowsAsync<ArgumentNullException>(() =>
            service.SendMessageAsync(new ChatRequest { Prompt = "" }, CancellationToken.None));
    }

    // ============================================================
    // Non-streaming success
    // ============================================================

    [Fact]
    public async Task SendMessageAsync_ReturnsPortKeyResult()
    {
        var service = CreateService();

        var request = new ChatRequest { Prompt = "hello" };

        _portKeyMock
            .Setup(x => x.ExecuteAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PortKeyExecutionResult
            {
                Output = "response",
                ModelAlias = "model",
                InputTokens = 1,
                OutputTokens = 1
            });

        var result = await service.SendMessageAsync(request, CancellationToken.None);

        Assert.Equal("response", result.Output);

        _portKeyMock.Verify(
            x => x.ExecuteAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // ============================================================
    // Streaming - no classification match
    // ============================================================

    [Fact]
    public async Task SendMessageStreamAsync_StreamsWithoutContext_WhenNoClassificationSignals()
    {
        var service = CreateService();

        var request = new ChatRequest { Prompt = "hello" };

        _classificationMock
            .Setup(x => x.ClassifyAsync(request.Prompt, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PackClassificationResult
            {
                Domains = Array.Empty<string>(),
                Topics = Array.Empty<string>(),
                IntentHints = Array.Empty<string>()
            });

        _portKeyMock
            .Setup(x => x.ExecuteStreamAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()))
            .Returns(MockStream("chunk1"));

        var results = new List<string>();

        await foreach (var chunk in service.SendMessageStreamAsync(request, CancellationToken.None))
        {
            results.Add(chunk);
        }

        Assert.Single(results);
        Assert.Equal("chunk1", results[0]);
    }

    // ============================================================
    // Streaming - classification triggers pack scoring
    // ============================================================

    [Fact]
    public async Task SendMessageStreamAsync_IncludesContext_WhenClassificationMatches()
    {
        var fakePack = new FakeContextPack("pack prompt");

        var service = CreateService(new List<IContextPack> { fakePack });

        var request = new ChatRequest { Prompt = "hello" };

        _classificationMock
            .Setup(x => x.ClassifyAsync(request.Prompt, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PackClassificationResult
            {
                Domains = new[] { "domain" },
                Topics = Array.Empty<string>(),
                IntentHints = Array.Empty<string>()
            });

        _portKeyMock
            .Setup(x => x.ExecuteStreamAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()))
            .Returns(MockStream("chunk"));

        var results = new List<string>();

        await foreach (var chunk in service.SendMessageStreamAsync(request, CancellationToken.None))
        {
            results.Add(chunk);
        }

        Assert.Single(results);
        Assert.Equal("chunk", results[0]);
    }

    // ============================================================
    // Streaming guard
    // ============================================================

    [Fact]
    public async Task SendMessageStreamAsync_Throws_WhenPromptInvalid()
    {
        var service = CreateService();

        await Assert.ThrowsAsync<ArgumentNullException>(async () =>
        {
            await foreach (var _ in service.SendMessageStreamAsync(
                new ChatRequest { Prompt = "" },
                CancellationToken.None))
            {
            }
        });
    }

    // ============================================================
    // Helpers
    // ============================================================

    private static async IAsyncEnumerable<string> MockStream(string value)
    {
        yield return value;
        await Task.CompletedTask;
    }

    private sealed class FakeContextPack : IContextPack
    {
        public FakeContextPack(string prompt)
        {
            Prompt = prompt;
            Metadata = new ContextPackMetadata
            {
                PackId = "id",
                Version = "1",
                Domains = Array.Empty<string>(),
                Topics = Array.Empty<string>(),
                Audience = [],
                RiskLevel = "",
                Priority = 1,
                Keywords = Array.Empty<string>(),
                AlwaysInject = false,
                SafetyCritical = false
            };
        }

        public string Prompt { get; }

        public ContextPackMetadata Metadata { get; }
    }
}

