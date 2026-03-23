namespace Epic.Api.Models;

public sealed class AddAppRequest
{
    public required string Name { get; set; }
}

public sealed class OnboardAppRequest
{
    public required string Repo { get; set; }
    public required string Branch { get; set; }
}

public sealed class TriggerRunRequest
{
    public required string Branch { get; set; }
    public required string Environment { get; set; }
}
