namespace Epic.Api.Data.Entities;

public sealed class AppEntity
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public required string DisplayName { get; set; }
    public string? Description { get; set; }
    public required string AppType { get; set; }
    public required string Technology { get; set; }
    public required string Cloud { get; set; }
    public required string Environment { get; set; }
    public required string Team { get; set; }
    public required string Domain { get; set; }
    public required string GithubRepo { get; set; }
    public string GithubBranch { get; set; } = "main";

    // Version fields (nullable — only relevant for certain appTypes)
    public string? NodeVersion { get; set; }
    public string? PythonVersion { get; set; }
    public string? JavaVersion { get; set; }
    public string? DotnetVersion { get; set; }

    // AWS (nullable)
    public string? AwsAccountId { get; set; }
    public string? AwsS3 { get; set; }
    public string? AwsCloudfront { get; set; }
    public string? AwsEc2InstanceId { get; set; }

    // Azure (nullable)
    public string? AzureSubscription { get; set; }
    public string? AzureResourceGroup { get; set; }

    public string CreatedBy { get; set; } = "";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public string LastUpdatedBy { get; set; } = "";
    public DateTime LastUpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public List<PipelineRunEntity> Runs { get; set; } = [];
    public List<UserAppEntity> UserApps { get; set; } = [];
}
