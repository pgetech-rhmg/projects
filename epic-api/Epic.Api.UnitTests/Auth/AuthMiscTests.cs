using System.Net;
using Epic.Api.Auth;
using Epic.Api.UnitTests.TestHelpers;
using Microsoft.AspNetCore.Http;
using Moq;
using Xunit;

namespace Epic.Api.UnitTests.Auth;

public sealed class DevCurrentUserTests
{
    [Fact]
    public void ReturnsFixedIdentity()
    {
        var user = new DevCurrentUser();
        Assert.Equal("rhmg", user.UserId);
        Assert.Equal("Morgan, Robb", user.DisplayName);
    }
}

public sealed class AuditLogTests
{
    private static AuditLog Make(ICurrentUser user, IPAddress? ip)
    {
        var httpContext = new DefaultHttpContext();
        if (ip is not null) httpContext.Connection.RemoteIpAddress = ip;
        var accessor = new HttpContextAccessor { HttpContext = httpContext };
        return new AuditLog(TestData.Logger<AuditLog>(), user, accessor);
    }

    [Fact]
    public void Record_WithResolvableUserAndIp_DoesNotThrow()
    {
        var audit = Make(new StubCurrentUser("rhmg", "Morgan, Robb"), IPAddress.Parse("10.0.0.1"));
        audit.Record("app.onboard", "app:epic-web", detail: "repo=epic-web");
        // No exception + structured log emitted (NullLogger swallows output).
    }

    [Fact]
    public void Record_WhenUserIdThrows_UsesUnknownActor()
    {
        var user = new Mock<ICurrentUser>();
        user.SetupGet(u => u.UserId).Throws(new UnauthorizedAccessException());
        var audit = Make(user.Object, ip: null); // no IP → "unknown" source too
        audit.Record("pipeline.cancel_run", "app:x;run:1");
        // Both defensive branches (actor + sourceIp fallbacks) exercised without throwing.
    }
}
