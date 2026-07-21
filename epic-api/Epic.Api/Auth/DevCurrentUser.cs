namespace Epic.Api.Auth;

/// <summary>
/// Fixed development identity used when authentication is bypassed in the
/// Development environment (see Program.cs). Keeps local `dotnet run` working
/// without a real Entra ID token. The corpId matches the seeded local user.
/// </summary>
public sealed class DevCurrentUser : ICurrentUser
{
    public string UserId => "rhmg";
    public string DisplayName => "Morgan, Robb";
}
