using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

using Moq;
using Xunit;

using Paige.Api.Controllers;
using Paige.Api.Engine.CfnConverter.Scan;

namespace Paige.Api.Tests.Controllers;

public sealed class RepoScanControllerTests
{
    private readonly Mock<IRepoScanService> _serviceMock;

    public RepoScanControllerTests()
    {
        _serviceMock = new Mock<IRepoScanService>(MockBehavior.Strict);
    }

    private RepoScanController CreateController()
    {
        return new RepoScanController(_serviceMock.Object);
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
    // RepoName null
    // ============================================================

    [Fact]
    public async Task ScanAsync_ReturnsBadRequest_WhenRepoNameIsNull()
    {
        var controller = CreateController();

        var request = new RepoScanRequest
        {
            RepoName = null!
        };

        var result = await controller.ScanAsync(request, CancellationToken.None);

        var badRequest = Assert.IsType<BadRequestObjectResult>(result);
        Assert.Equal("RepoName is required.", badRequest.Value);
    }

    // ============================================================
    // RepoName whitespace
    // ============================================================

    [Fact]
    public async Task ScanAsync_ReturnsBadRequest_WhenRepoNameIsWhitespace()
    {
        var controller = CreateController();

        var request = new RepoScanRequest
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

        var request = new RepoScanRequest
        {
            RepoName = "repo-test"
        };

        var expected = new RepoScanResult();

        _serviceMock
            .Setup(x => x.ScanAsync(request, It.IsAny<CancellationToken>()))
            .ReturnsAsync(expected);

        var result = await controller.ScanAsync(request, CancellationToken.None);

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.Equal(expected, ok.Value);

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

        var request = new RepoScanRequest
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

        var request = new RepoScanRequest
        {
            RepoName = "error-repo"
        };

        _serviceMock
            .Setup(x => x.ScanAsync(request, It.IsAny<CancellationToken>()))
            .ThrowsAsync(new Exception("boom"));

        var result = await controller.ScanAsync(request, CancellationToken.None);

        var status = Assert.IsType<ObjectResult>(result);

        Assert.Equal(StatusCodes.Status500InternalServerError, status.StatusCode);

        var payload = status.Value;
        Assert.NotNull(payload);

        var errorProp = payload!.GetType().GetProperty("error");
        var detailProp = payload.GetType().GetProperty("detail");

        Assert.NotNull(errorProp);
        Assert.NotNull(detailProp);

        Assert.Equal("Repo scan failed.", errorProp!.GetValue(payload));
        Assert.Equal("boom", detailProp!.GetValue(payload));

        _serviceMock.Verify(
            x => x.ScanAsync(request, It.IsAny<CancellationToken>()),
            Times.Once);
    }
}

