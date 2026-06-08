namespace Epic.Api.Auth;

/// <summary>
/// Reads user identity from X-Epic-User header.
/// Replace with MSAL/JWT identity when auth is wired up.
/// </summary>
public sealed class HeaderCurrentUser(IHttpContextAccessor httpContextAccessor) : ICurrentUser
{
    public string UserId =>
        httpContextAccessor.HttpContext?.Request.Headers["X-Epic-User"].FirstOrDefault()
        ?? throw new UnauthorizedAccessException("X-Epic-User header is required");
}
