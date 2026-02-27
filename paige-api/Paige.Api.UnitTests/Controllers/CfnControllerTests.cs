using System.Text;
using System.Text.Json;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

using Moq;
using Xunit;

using Paige.Api.Controllers;
using Paige.Api.Engine.CfnConverter.Cfn;
using Paige.Api.Engine.CfnConverter.Terraform;
using Paige.Api.Engine.Job;
using Paige.Api.Engine.PortKey;

namespace Paige.Api.Tests.Controllers;

[CollectionDefinition(nameof(CfnControllerTests), DisableParallelization = true)]
public sealed class CfnControllerTestsCollection
{
}

[Collection(nameof(CfnControllerTests))]
public sealed class CfnControllerTests
{
    private readonly Mock<IPortKeyExecutionService> _portKeyMock;

    public CfnControllerTests()
    {
        _portKeyMock = new Mock<IPortKeyExecutionService>(MockBehavior.Strict);
    }

    private CfnController CreateController(out DefaultHttpContext httpContext)
    {
        var cfnExecutionService = new CfnExecutionService(_portKeyMock.Object);
        var terraformProjectBuilder = new TerraformProjectBuilder();

        var controller = new CfnController(cfnExecutionService, terraformProjectBuilder);

        httpContext = new DefaultHttpContext();
        httpContext.Response.Body = new MemoryStream();

        controller.ControllerContext = new ControllerContext
        {
            HttpContext = httpContext
        };

        return controller;
    }

    // ============================================================
    // CreateProject
    // ============================================================

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public void CreateProject_ReturnsBadRequest_WhenNoTemplatesProvided(bool useNull)
    {
        var controller = CreateController(out _);

        var request = new CfnGenerationResponse
        {
            CfnResults = useNull ? null! : []
        };

        var result = controller.CreateProject(request);

        var badRequest = Assert.IsType<BadRequestObjectResult>(result.Result);
        Assert.Equal("No CloudFormation templates provided.", badRequest.Value);
    }

    [Fact]
    public void CreateProject_ReturnsOk_WithTerraformGenerationResponse_WhenValid()
    {
        var controller = CreateController(out _);

        using var filesDoc = JsonDocument.Parse("""
        {
          "main.tf": "hello",
          "variables.tf": "vars"
        }
        """);

        var request = new CfnGenerationResponse
        {
            CfnResults =
            [
                new CfnResult
                {
                    Module = "my-module",
                    Files = filesDoc.RootElement.Clone()
                }
            ]
        };

        var result = controller.CreateProject(request);

        var ok = Assert.IsType<OkObjectResult>(result.Result);

        // Build(...) returns TerraformGenerationResponse in YOUR codebase
        var payload = Assert.IsType<TerraformGenerationResponse>(ok.Value);

        // Validate that the project builder output looks right
        Assert.NotNull(payload.Files);
        Assert.True(payload.Files.ContainsKey("main.tf"));
        Assert.True(payload.Files.ContainsKey("providers.tf"));
        Assert.True(payload.Files.ContainsKey("versions.tf"));
        Assert.True(payload.Files.ContainsKey("variables.tf"));
        Assert.True(payload.Files.ContainsKey("outputs.tf"));

        // module files are placed under modules/<module>/
        Assert.True(payload.Files.ContainsKey("modules/my-module/main.tf"));
        Assert.True(payload.Files.ContainsKey("modules/my-module/variables.tf"));
        Assert.Equal("hello", payload.Files["modules/my-module/main.tf"]);
        Assert.Equal("vars", payload.Files["modules/my-module/variables.tf"]);
    }

    // ============================================================
    // StartGeneration
    // ============================================================

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public void StartGeneration_ReturnsBadRequest_WhenNoCfnsProvided(bool useNull)
    {
        var controller = CreateController(out _);

        var request = new CfnGenerationRequest
        {
            Cfns = useNull ? null! : []
        };

        var result = controller.StartGeneration(request);

        var badRequest = Assert.IsType<BadRequestObjectResult>(result.Result);
        Assert.Equal("No CloudFormation templates provided.", badRequest.Value);
    }

    [Fact]
    public void StartGeneration_ReturnsOk_WithJobId_WhenValid()
    {
        var controller = CreateController(out _);

        var request = new CfnGenerationRequest
        {
            Cfns =
            [
                new CfnInput { Module = "m1", RawCfn = "{ }" }
            ]
        };

        var result = controller.StartGeneration(request);

        var ok = Assert.IsType<OkObjectResult>(result.Result);
        var payload = Assert.IsType<JobResponse>(ok.Value);

        Assert.False(string.IsNullOrWhiteSpace(payload.JobId));

        // sanity: job exists
        Assert.True(JobStore<IReadOnlyList<CfnInput>>.TryGetJob(payload.JobId, out _));

        // cleanup
        JobStore<IReadOnlyList<CfnInput>>.CompleteJob(payload.JobId);
    }

    // ============================================================
    // StreamGeneration - NotFound
    // ============================================================

    [Fact]
    public async Task StreamGeneration_Sets404_WhenJobNotFound()
    {
        var controller = CreateController(out var httpContext);

        await controller.StreamGeneration("does-not-exist", CancellationToken.None);

        Assert.Equal(StatusCodes.Status404NotFound, httpContext.Response.StatusCode);
    }

    // ============================================================
    // StreamGeneration - Success (covers ProcessModuleAsync + WriteStreamAsync)
    // ============================================================

    [Fact]
    public async Task StreamGeneration_WritesDataEvents_AndCompleteEvent_WhenSuccessful()
    {
        var controller = CreateController(out var httpContext);

        var jobId = JobStore<IReadOnlyList<CfnInput>>.CreateJob(
            new List<CfnInput>
            {
                new CfnInput { Module = "module-a", RawCfn = "{ }" }
            });

        var toolOutput = """
        ```json
        {
          "files": {
            "main.tf": "content"
          }
        }
        ```
        """;

        _portKeyMock
            .Setup(x => x.ExecuteAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new PortKeyExecutionResult
            {
                Output = toolOutput,
                ModelAlias = "test",
                InputTokens = 1,
                OutputTokens = 1
            });

        await controller.StreamGeneration(jobId, CancellationToken.None);

        Assert.Equal("text/event-stream", httpContext.Response.Headers["Content-Type"].ToString());
        Assert.Equal("no-cache", httpContext.Response.Headers["Cache-Control"].ToString());
        Assert.Equal("no", httpContext.Response.Headers["X-Accel-Buffering"].ToString());
        Assert.Equal("keep-alive", httpContext.Response.Headers["Connection"].ToString());
        Assert.Equal("none", httpContext.Response.Headers["Content-Encoding"].ToString());

        httpContext.Response.Body.Position = 0;

        var body = await new StreamReader(httpContext.Response.Body, Encoding.UTF8).ReadToEndAsync();

        Assert.Contains("data:", body);
        Assert.Contains("\"module\":\"module-a\"", body);
        Assert.Contains("\"files\":", body);
        Assert.Contains("event: complete", body);

        _portKeyMock.Verify(
            x => x.ExecuteAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // ============================================================
    // StreamGeneration - OperationCanceledException branch
    // (throws OCE from ExecuteAsync without canceling the linked token)
    // ============================================================

    [Fact]
    public async Task StreamGeneration_CatchesOperationCanceledException_FromExecutionTasks_AndStillCompletesStream()
    {
        var controller = CreateController(out var httpContext);

        var jobId = JobStore<IReadOnlyList<CfnInput>>.CreateJob(
            new List<CfnInput>
            {
                new CfnInput { Module = "module-cancel", RawCfn = "{ }" }
            });

        _portKeyMock
            .Setup(x => x.ExecuteAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new OperationCanceledException());

        await controller.StreamGeneration(jobId, CancellationToken.None);

        httpContext.Response.Body.Position = 0;

        var body = await new StreamReader(httpContext.Response.Body, Encoding.UTF8).ReadToEndAsync();

        // even though a module task threw OCE, the controller completes the SSE stream
        Assert.Contains("event: complete", body);

        _portKeyMock.Verify(
            x => x.ExecuteAsync(It.IsAny<PortKeyPromptEnvelope>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // ============================================================
    // Cancel
    // ============================================================

    [Fact]
    public void Cancel_ReturnsNoContent_AndRemovesJob()
    {
        var controller = CreateController(out _);

        var jobId = JobStore<IReadOnlyList<CfnInput>>.CreateJob(
            new List<CfnInput>
            {
                new CfnInput { Module = "m", RawCfn = "{ }" }
            });

        var result = controller.Cancel(jobId);

        Assert.IsType<NoContentResult>(result);
        Assert.False(JobStore<IReadOnlyList<CfnInput>>.TryGetJob(jobId, out _));
    }
}

