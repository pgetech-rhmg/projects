using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

using Moq;
using Xunit;

using Paige.Api.Controllers;
using Paige.Api.Engine.RepoAssessment;
using Paige.Api.Engine.RepoAssessment.Ai;

namespace Paige.Api.Tests.Controllers;

public sealed class RepoAssessmentControllerTests
{
    private readonly Mock<IRepoAssessmentService> _serviceMock;
    private readonly Mock<RepoAssessmentAiService> _aiServiceMock;

    public RepoAssessmentControllerTests()
    {
        _serviceMock = new Mock<IRepoAssessmentService>(MockBehavior.Strict);
        _aiServiceMock = new Mock<RepoAssessmentAiService>(MockBehavior.Strict);
    }

    private RepoAssessmentController CreateController()
    {
        return new RepoAssessmentController(_serviceMock.Object, _aiServiceMock.Object);
    }

    // ============================================================
    // Null request
    // ============================================================

    [Fact]
    public async Task ScanAsync_ReturnsBadRequest_WhenRequestIsNull()
    {
        var controller = CreateController();

        var result = await controller.ScanAsync(null!, CancellationToken.None);

        var badRequest = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Equal("Request body is required.", badRequest.Value);
    }

    // ============================================================
    // Missing RepoName (null)
    // ============================================================

    [Fact]
    public async Task ScanAsync_ReturnsBadRequest_WhenRepoNameIsNull()
    {
        var controller = CreateController();

        var request = new RepoAssessmentRequest
        {
            RepoName = null!
        };

        var result = await controller.ScanAsync(request, CancellationToken.None);

        var badRequest = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Equal("RepoName is required.", badRequest.Value);
    }

    // ============================================================
    // Missing RepoName (whitespace)
    // ============================================================

    [Fact]
    public async Task ScanAsync_ReturnsBadRequest_WhenRepoNameIsWhitespace()
    {
        var controller = CreateController();

        var request = new RepoAssessmentRequest
        {
            RepoName = "   "
        };

        var result = await controller.ScanAsync(request, CancellationToken.None);

        var badRequest = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Equal("RepoName is required.", badRequest.Value);
    }

    // ============================================================
    // Success
    // ============================================================

    [Fact]
    public async Task ScanAsync_ReturnsOk_WhenSuccessful()
    {
        var controller = CreateController();

        var request = new RepoAssessmentRequest
        {
            RepoName = "test-repo"
        };

        var expectedResult = new RepoAssessmentResult();

        _serviceMock
            .Setup(x => x.ScanAsync(request, It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedResult);

        var result = await controller.ScanAsync(request, CancellationToken.None);

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.Equal(expectedResult, ok.Value);

        _serviceMock.Verify(
            x => x.ScanAsync(request, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // ============================================================
    // OperationCanceledException -> 499
    // ============================================================

    [Fact]
    public async Task ScanAsync_Returns499_WhenCancelled()
    {
        var controller = CreateController();

        var request = new RepoAssessmentRequest
        {
            RepoName = "cancelled-repo"
        };

        _serviceMock
            .Setup(x => x.ScanAsync(request, It.IsAny<CancellationToken>()))
            .ThrowsAsync(new OperationCanceledException());

        var result = await controller.ScanAsync(request, CancellationToken.None);

        var status = Assert.IsType<ObjectResult>(result);

        Assert.Equal(StatusCodes.Status499ClientClosedRequest, status.StatusCode);
        Assert.Equal("Request was cancelled.", status.Value);

        _serviceMock.Verify(
            x => x.ScanAsync(request, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // ============================================================
    // Exception -> 500
    // ============================================================

    [Fact]
    public async Task ScanAsync_Returns500_WhenExceptionThrown()
    {
        var controller = CreateController();

        var request = new RepoAssessmentRequest
        {
            RepoName = "error-repo"
        };

        _serviceMock
            .Setup(x => x.ScanAsync(request, It.IsAny<CancellationToken>()))
            .ThrowsAsync(new Exception("boom"));

        var result = await controller.ScanAsync(request, CancellationToken.None);

        var status = Assert.IsType<ObjectResult>(result);

        Assert.Equal(StatusCodes.Status500InternalServerError, status.StatusCode);

        // Anonymous object: { error = "...", detail = ex.Message }
        var payload = status.Value;

        Assert.NotNull(payload);

        var errorProperty = payload!.GetType().GetProperty("error");
        var detailProperty = payload.GetType().GetProperty("detail");

        Assert.NotNull(errorProperty);
        Assert.NotNull(detailProperty);

        Assert.Equal("Repo scan failed.", errorProperty!.GetValue(payload));
        Assert.Equal("boom", detailProperty!.GetValue(payload));

        _serviceMock.Verify(
            x => x.ScanAsync(request, It.IsAny<CancellationToken>()),
            Times.Once);
    }
}

