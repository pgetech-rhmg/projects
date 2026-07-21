using Epic.Api.Controllers;
using Epic.Api.Models;
using Epic.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Xunit;

namespace Epic.Api.UnitTests.Controllers;

public sealed class UserAppsControllerTests
{
    private readonly Mock<IAppService> _svc = new();
    private UserAppsController Sut() => new(_svc.Object);

    private static ManagedApp Managed(string name = "epic-web") => new()
    {
        Name = name, Technology = "Angular", Cloud = "AWS", Environment = "dev"
    };

    [Fact]
    public async Task GetMyApps_Ok()
    {
        _svc.Setup(s => s.GetUserAppsAsync(It.IsAny<CancellationToken>())).ReturnsAsync([Managed()]);
        var ok = Assert.IsType<OkObjectResult>(await Sut().GetMyApps(default));
        Assert.IsAssignableFrom<List<ManagedApp>>(ok.Value);
    }

    [Fact]
    public async Task AddToMyApps_Created()
    {
        _svc.Setup(s => s.AddToMyAppsAsync("epic-web", It.IsAny<CancellationToken>())).ReturnsAsync(Managed());
        var result = await Sut().AddToMyApps(new AddAppRequest { Name = "epic-web" }, default);
        Assert.IsType<CreatedResult>(result);
    }

    [Fact]
    public async Task RemoveFromMyApps_NoContent()
    {
        _svc.Setup(s => s.RemoveFromMyAppsAsync("epic-web", It.IsAny<CancellationToken>())).Returns(Task.CompletedTask);
        Assert.IsType<NoContentResult>(await Sut().RemoveFromMyApps("epic-web", default));
    }

    [Fact]
    public async Task RemoveFromMyApps_KeyNotFound_NotFound()
    {
        _svc.Setup(s => s.RemoveFromMyAppsAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new KeyNotFoundException());
        Assert.IsType<NotFoundResult>(await Sut().RemoveFromMyApps("x", default));
    }
}
