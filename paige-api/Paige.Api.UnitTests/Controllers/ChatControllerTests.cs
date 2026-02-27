using System.Text;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

using Moq;
using Xunit;

using Paige.Api.Controllers;
using Paige.Api.Engine.Chat;
using Paige.Api.Engine.Job;
using Paige.Api.Engine.PortKey;
using Paige.Api.Packs;

namespace Paige.Api.Tests.Controllers;

[CollectionDefinition(nameof(ChatControllerTests), DisableParallelization = true)]
public sealed class ChatControllerTestsCollection
{
}

[Collection(nameof(ChatControllerTests))]
public sealed class ChatControllerTests
{
    private readonly Mock<IPortKeyExecutionService> _portKeyMock;
    private readonly Mock<IPackClassificationService> _classificationMock;

    public ChatControllerTests()
    {
        _portKeyMock = new Mock<IPortKeyExecutionService>(MockBehavior.Strict);
        _classificationMock = new Mock<IPackClassificationService>(MockBehavior.Strict);
    }

    private ChatController CreateController(out DefaultHttpContext httpContext)
    {
        // Keep packs empty so baseline is empty and classification won’t include extra packs.
        var packs = new List<IContextPack>();

        var loader = new BaselinePackLoader(packs);
        var baselineProvider = new BaselinePromptProvider(loader);

        var packScoringService = new PackScoringService();

        var chatExecutionService = new ChatExecutionService(
            packs,
            _portKeyMock.Object,
            baselineProvider,
            _classificationMock.Object,
            packScoringService);

        var controller = new ChatController(chatExecutionService);

        httpContext = new DefaultHttpContext();
        httpContext.Response.Body = new MemoryStream();

        controller.ControllerContext = new ControllerContext
        {
            HttpContext = httpContext
        };

        return controller;
    }

    // ============================================================
    // SendMessage (non-streaming)
    // ============================================================

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public async Task SendMessage_ReturnsBadRequest_WhenInvalid(bool useNull)
    {
        var controller = CreateController(out _);

        ChatRequest? request = useNull
            ? null
            : new ChatRequest { Prompt = "" };

        var result = await controller.SendMessage(request!, CancellationToken.None);

        var badRequest = Assert.IsType<BadRequestObjectResult>(result.Result);
        Assert.Equal("No message provided.", badRequest.Value);
    }

    [Fact]
    public async Task SendMessage_ReturnsOk_WhenValid()
    {
        var controller = CreateController(out _);

        var request = new ChatRequest { Prompt = "hello" };

        _portKeyMock
            .Setup(x => x.ExecuteAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PortKeyExecutionResult
            {
                Output = "response",
                ModelAlias = "test",
                InputTokens = 1,
                OutputTokens = 1
            });

        var result = await controller.SendMessage(request, CancellationToken.None);

        var ok = Assert.IsType<OkObjectResult>(result.Result);

        // Controller returns Ok(response) where response is PortKeyExecutionResult
        var payload = Assert.IsType<PortKeyExecutionResult>(ok.Value);
        Assert.Equal("response", payload.Output);

        _portKeyMock.Verify(
            x => x.ExecuteAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // ============================================================
    // StartChat
    // ============================================================

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public void StartChat_ReturnsBadRequest_WhenInvalid(bool useNull)
    {
        var controller = CreateController(out _);

        ChatRequest? request = useNull
            ? null
            : new ChatRequest { Prompt = "" };

        var result = controller.StartChat(request!);

        var badRequest = Assert.IsType<BadRequestObjectResult>(result.Result);
        Assert.Equal("No message provided.", badRequest.Value);
    }

    [Fact]
    public void StartChat_ReturnsJobId_WhenValid()
    {
        var controller = CreateController(out _);

        var request = new ChatRequest { Prompt = "hello" };

        var result = controller.StartChat(request);

        var ok = Assert.IsType<OkObjectResult>(result.Result);
        var payload = Assert.IsType<JobResponse>(ok.Value);

        Assert.False(string.IsNullOrWhiteSpace(payload.JobId));
        Assert.True(JobStore<ChatRequest>.TryGetJob(payload.JobId, out _));

        JobStore<ChatRequest>.CompleteJob(payload.JobId);
    }

    // ============================================================
    // StreamChat - 404
    // ============================================================

    [Fact]
    public async Task StreamChat_Sets404_WhenJobNotFound()
    {
        var controller = CreateController(out var context);

        await controller.StreamChat("missing", CancellationToken.None);

        Assert.Equal(StatusCodes.Status404NotFound, context.Response.StatusCode);
    }

    // ============================================================
    // StreamChat - Success
    // ============================================================

    [Fact]
    public async Task StreamChat_WritesChunks_AndCompleteEvent()
    {
        var controller = CreateController(out var context);

        var jobId = JobStore<ChatRequest>.CreateJob(new ChatRequest { Prompt = "hello" });

        _classificationMock
            .Setup(x => x.ClassifyAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PackClassificationResult
            {
                Domains = Array.Empty<string>(),
                Topics = Array.Empty<string>(),
                IntentHints = Array.Empty<string>()
            });

        _portKeyMock
            .Setup(x => x.ExecuteStreamAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()))
            .Returns(MockStream("line1\r\nline2"));

        await controller.StreamChat(jobId, CancellationToken.None);

        Assert.Equal("text/event-stream", context.Response.Headers["Content-Type"].ToString());
        Assert.Equal("no-cache, no-transform", context.Response.Headers["Cache-Control"].ToString());
        Assert.Equal("no", context.Response.Headers["X-Accel-Buffering"].ToString());
        Assert.Equal("keep-alive", context.Response.Headers["Connection"].ToString());

        context.Response.Body.Position = 0;

        var body = await new StreamReader(context.Response.Body, Encoding.UTF8).ReadToEndAsync();

        Assert.Contains("data: line1", body);
        Assert.Contains("data: line2", body);
        Assert.Contains("event: complete", body);

        _portKeyMock.Verify(
            x => x.ExecuteStreamAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // ============================================================
    // StreamChat - Cancellation branch
    // ============================================================

    [Fact]
    public async Task StreamChat_CatchesOperationCanceledException_AndStillCompletes()
    {
        var controller = CreateController(out var context);

        var jobId = JobStore<ChatRequest>.CreateJob(new ChatRequest { Prompt = "cancel" });

        _classificationMock
            .Setup(x => x.ClassifyAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PackClassificationResult
            {
                Domains = Array.Empty<string>(),
                Topics = Array.Empty<string>(),
                IntentHints = Array.Empty<string>()
            });

        _portKeyMock
            .Setup(x => x.ExecuteStreamAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()))
            .Throws(new OperationCanceledException());

        await controller.StreamChat(jobId, CancellationToken.None);

        context.Response.Body.Position = 0;

        var body = await new StreamReader(context.Response.Body, Encoding.UTF8).ReadToEndAsync();

        Assert.Contains("event: complete", body);
    }

    // ============================================================
    // CancelChat
    // ============================================================

    [Fact]
    public void CancelChat_RemovesJob_AndReturnsNoContent()
    {
        var controller = CreateController(out _);

        var jobId = JobStore<ChatRequest>.CreateJob(new ChatRequest { Prompt = "hello" });

        var result = controller.CancelChat(jobId);

        Assert.IsType<NoContentResult>(result);
        Assert.False(JobStore<ChatRequest>.TryGetJob(jobId, out _));
    }

    // ============================================================
    // Helper: async stream for ExecuteStreamAsync
    // ============================================================

    private static async IAsyncEnumerable<string> MockStream(string value)
    {
        yield return value;
        await Task.CompletedTask;
    }
}

