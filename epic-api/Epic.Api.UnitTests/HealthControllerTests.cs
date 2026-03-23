using Epic.Api.Controllers;
using Microsoft.AspNetCore.Mvc;
using Xunit;

namespace Epic.Api.UnitTests;

public class HealthControllerTests
{
    [Fact]
    public void Get_ReturnsOkWithHealthyStatus()
    {
        var controller = new HealthController();

        var result = controller.Get() as OkObjectResult;

        Assert.NotNull(result);
        Assert.Equal(200, result.StatusCode);
    }
}
