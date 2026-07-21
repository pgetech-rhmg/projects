using Epic.Api.Controllers;
using Epic.Api.UnitTests.TestHelpers;
using Microsoft.AspNetCore.Mvc;
using Xunit;

namespace Epic.Api.UnitTests.Controllers;

public sealed class HealthControllerTests
{
    [Fact]
    public async Task Get_WithReachableDb_Returns200Healthy()
    {
        using var db = TestData.NewDb();
        var result = await new HealthController(db).Get() as ObjectResult;
        Assert.NotNull(result);
        Assert.Equal(200, result!.StatusCode);
    }

    [Fact]
    public async Task Get_WhenDbThrows_Returns503Degraded()
    {
        using var db = TestData.NewDb();
        db.Dispose(); // CanConnectAsync throws on a disposed context → caught → degraded
        var result = await new HealthController(db).Get() as ObjectResult;
        Assert.NotNull(result);
        Assert.Equal(503, result!.StatusCode);
    }
}
