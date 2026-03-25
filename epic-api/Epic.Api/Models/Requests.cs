using System.ComponentModel.DataAnnotations;

namespace Epic.Api.Models;

public sealed class AddAppRequest
{
    [Required, StringLength(200, MinimumLength = 1)]
    public required string Name { get; set; }
}

public sealed class OnboardAppRequest
{
    [Required, StringLength(200, MinimumLength = 1)]
    public required string Repo { get; set; }

    [Required, StringLength(200, MinimumLength = 1)]
    public required string Branch { get; set; }
}

public sealed class TriggerRunRequest
{
    [Required, StringLength(200, MinimumLength = 1)]
    public required string Branch { get; set; }

    [Required, RegularExpression("^(dev|test|qa|stage|prod)$", ErrorMessage = "Environment must be dev, test, qa, stage, or prod.")]
    public required string Environment { get; set; }

    public bool Build { get; set; } = true;
    public bool Tests { get; set; }
    public bool Scan { get; set; }
    public bool Deploy { get; set; }
    public bool Integrations { get; set; }

    [RegularExpression("^(none|apply|destroy)$", ErrorMessage = "DeployInfra must be none, apply, or destroy.")]
    public string DeployInfra { get; set; } = "none";
}

public sealed class TriggerRunResponse
{
    public int RunId { get; set; }
    public required string Url { get; set; }
}
