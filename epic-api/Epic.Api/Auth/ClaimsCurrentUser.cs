using System.Security.Claims;
using System.Text.RegularExpressions;

namespace Epic.Api.Auth;

/// <summary>
/// Resolves the current user from the validated Entra ID (MSAL) token claims.
///
/// Identity: corpId is derived from the email local-part, per the PG&amp;E
/// invariant that every corporate email is &lt;4charCorpId&gt;@pge.com. Mirrors the
/// CMA authorizer (projects/cma-react-app/backend/authorizer) and the UI-side
/// derivation. Replaces the prior X-Epic-User header trust model.
/// </summary>
public sealed partial class ClaimsCurrentUser(IHttpContextAccessor httpContextAccessor) : ICurrentUser
{
    // PG&E corpIds are exactly 4 alphanumeric characters (the email local-part).
    [GeneratedRegex(@"^[a-z0-9]{4}$")]
    private static partial Regex CorpIdShape();

    private ClaimsPrincipal User =>
        httpContextAccessor.HttpContext?.User
        ?? throw new UnauthorizedAccessException("No authenticated user on the request.");

    public string UserId
    {
        get
        {
            var corpId = DeriveCorpId(User);
            if (corpId is null)
                throw new UnauthorizedAccessException("Token is valid but a PG&E corpId could not be derived.");
            return corpId;
        }
    }

    public string DisplayName =>
        User.FindFirst("name")?.Value
        ?? User.FindFirst(ClaimTypes.Name)?.Value
        ?? UserId;

    private static string? DeriveCorpId(ClaimsPrincipal user)
    {
        var email =
            user.FindFirst("email")?.Value
            ?? user.FindFirst("preferred_username")?.Value
            ?? user.FindFirst("upn")?.Value
            ?? user.FindFirst(ClaimTypes.Upn)?.Value
            ?? user.FindFirst(ClaimTypes.Email)?.Value;

        if (string.IsNullOrWhiteSpace(email))
            return null;

        var localPart = email.ToLowerInvariant().Split('@')[0];
        return CorpIdShape().IsMatch(localPart) ? localPart : null;
    }
}
