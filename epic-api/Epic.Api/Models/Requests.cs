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
    public bool Build { get; set; } = true;
    public bool Tests { get; set; }
    public bool Scan { get; set; }
    public bool Deploy { get; set; }
    public bool Integrations { get; set; }
    public string DeployInfra { get; set; } = "none";
}

public sealed class TriggerRunResponse
{
    public int RunId { get; set; }
    public required string Url { get; set; }
}
