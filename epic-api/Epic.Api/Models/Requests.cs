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

    /// <summary>
    /// Named GitHub source (org + host) the repo lives in. Null falls back to
    /// the default source, preserving single-org behavior.
    /// </summary>
    [StringLength(100)]
    public string? Source { get; set; }
}

public sealed class TriggerRunRequest
{
    [Required, StringLength(200, MinimumLength = 1)]
    public required string Branch { get; set; }

    [Required, RegularExpression("^(dev|test|qa|stage|prod|other)$", ErrorMessage = "Environment must be dev, test, qa, stage, prod, or other.")]
    public required string Environment { get; set; }

    // Optional stage toggles. Nullable so the model binder can tell "omitted"
    // from an explicit false (SonarQube S6964); the controller applies the
    // documented defaults via ?? when it reads them.
    public bool? Review { get; set; }
    public bool? Build { get; set; }
    public bool? Tests { get; set; }
    public bool? Scan { get; set; }
    public bool? Deploy { get; set; }
    public bool? Integrations { get; set; }

    [StringLength(500, MinimumLength = 1)]
    public string Config { get; set; } = ".pipeline/epic.json";

    [RegularExpression("^(none|plan|apply|destroy)$", ErrorMessage = "DeployInfra must be none, plan, apply, or destroy.")]
    public string DeployInfra { get; set; } = "none";

    /// <summary>
    /// When the repo has a committed tfstate, copy it into the S3 backend on
    /// init (answers Terraform's state-migration prompt non-interactively).
    /// Ignored unless an infra deploy is requested.
    /// </summary>
    public bool? ForceStateCopy { get; set; }

    // Documented defaults: Review/Build default on, everything else off.
    public bool ReviewOrDefault => Review ?? true;
    public bool BuildOrDefault => Build ?? true;
    public bool TestsOrDefault => Tests ?? false;
    public bool ScanOrDefault => Scan ?? false;
    public bool DeployOrDefault => Deploy ?? false;
    public bool IntegrationsOrDefault => Integrations ?? false;
    public bool ForceStateCopyOrDefault => ForceStateCopy ?? false;
}

public sealed class TriggerRunResponse
{
    public int RunId { get; set; }
    public required string Url { get; set; }
}
