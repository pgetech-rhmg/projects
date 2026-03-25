using Epic.Api.Controllers;
using Epic.Api.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace Epic.Api.UnitTests;

public class HealthControllerTests
{
    [Fact]
    public async Task Get_WithHealthyDb_Returns200()
    {
        var options = new DbContextOptionsBuilder<EpicDbContext>()
            .UseInMemoryDatabase("HealthTest_Healthy")
            .Options;
        using var db = new EpicDbContext(options);
        var controller = new HealthController(db);

        var result = await controller.Get() as ObjectResult;

        Assert.NotNull(result);
        Assert.Equal(200, result.StatusCode);
    }
}
