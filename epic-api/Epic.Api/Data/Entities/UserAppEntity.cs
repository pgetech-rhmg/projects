namespace Epic.Api.Data.Entities;

public sealed class UserAppEntity
{
    public int Id { get; set; }
    public required string UserId { get; set; }
    public int AppId { get; set; }
    public DateTime AddedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public AppEntity App { get; set; } = null!;
}
