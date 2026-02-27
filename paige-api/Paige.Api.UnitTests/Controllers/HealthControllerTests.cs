using Xunit;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Paige.Api.Controllers;

namespace Paige.Api.UnitTests.Controllers;

public sealed class HealthControllerTests
{
    [Fact]
    public void Get_Should_Return_200_With_Expected_HealthResponse()
    {
        // Arrange
        var sut = new HealthController();

        var before = DateTime.UtcNow;

        // Act
        var result = sut.Get();

        var after = DateTime.UtcNow;

        // Assert - Result Type
        result.Should().BeOfType<OkObjectResult>();

        var okResult = result as OkObjectResult;

        okResult!.StatusCode.Should().Be(200);

        okResult.Value.Should().NotBeNull();
        okResult.Value.Should().BeOfType<HealthResponse>();

        var response = okResult.Value as HealthResponse;

        // Assert - Properties
        response!.Status.Should().Be("Healthy");
        response.Service.Should().Be("PAIGE API");

        response.TimestampUtc.Kind.Should().Be(DateTimeKind.Utc);

        response.TimestampUtc.Should().BeOnOrAfter(before);
        response.TimestampUtc.Should().BeOnOrBefore(after);
    }
}

