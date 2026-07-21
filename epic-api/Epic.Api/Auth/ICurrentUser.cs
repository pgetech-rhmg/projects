namespace Epic.Api.Auth;

public interface ICurrentUser
{
    /// <summary>
    /// Stable identity key used to scope data (e.g. user_apps). The 4-char PG&E
    /// corpId derived from the authenticated user's email local-part.
    /// </summary>
    string UserId { get; }

    /// <summary>
    /// Human-readable display name for audit/display fields (CreatedBy,
    /// triggeredBy, etc.). Not a stable key — use <see cref="UserId"/> for that.
    /// </summary>
    string DisplayName { get; }
}
