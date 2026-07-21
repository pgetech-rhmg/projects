using System.Security.Claims;
using Epic.Api.Auth;
using Microsoft.AspNetCore.Http;
using Xunit;

namespace Epic.Api.UnitTests.Auth;

public sealed class ClaimsCurrentUserTests
{
    private static ClaimsCurrentUser With(params Claim[] claims)
    {
        var accessor = new HttpContextAccessor
        {
            HttpContext = new DefaultHttpContext
            {
                User = new ClaimsPrincipal(new ClaimsIdentity(claims, "test"))
            }
        };
        return new ClaimsCurrentUser(accessor);
    }

    [Fact]
    public void UserId_DerivesCorpIdFromEmail()
    {
        var user = With(new Claim("email", "RHMG@pge.com"), new Claim("name", "Morgan, Robb"));
        Assert.Equal("rhmg", user.UserId);
        Assert.Equal("Morgan, Robb", user.DisplayName);
    }

    [Theory]
    [InlineData("preferred_username", "abcd@pge.com", "abcd")]
    [InlineData("upn", "wxyz@pge.com", "wxyz")]
    public void UserId_FallsBackThroughClaimTypes(string claimType, string value, string expected)
    {
        var user = With(new Claim(claimType, value));
        Assert.Equal(expected, user.UserId);
    }

    [Fact]
    public void DisplayName_FallsBackToNameClaimTypeThenUserId()
    {
        // No "name" claim but the schema Name claim present.
        var user = With(new Claim("email", "rhmg@pge.com"), new Claim(ClaimTypes.Name, "Robb"));
        Assert.Equal("Robb", user.DisplayName);

        // Neither name claim → DisplayName falls through to UserId (corpId).
        var user2 = With(new Claim("email", "rhmg@pge.com"));
        Assert.Equal("rhmg", user2.DisplayName);
    }

    [Fact]
    public void UserId_NonCorpIdShape_Throws()
    {
        // Local part isn't the 4-char corpId shape → cannot derive.
        var user = With(new Claim("email", "firstname.lastname@pge.com"));
        Assert.Throws<UnauthorizedAccessException>(() => user.UserId);
    }

    [Fact]
    public void UserId_NoEmailClaim_Throws()
    {
        var user = With(new Claim("name", "Morgan, Robb"));
        Assert.Throws<UnauthorizedAccessException>(() => user.UserId);
    }

    [Fact]
    public void NoHttpContext_Throws()
    {
        var user = new ClaimsCurrentUser(new HttpContextAccessor { HttpContext = null });
        Assert.Throws<UnauthorizedAccessException>(() => user.UserId);
    }
}
