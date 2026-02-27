namespace Paige.Api.Engine.CfnConverter.Scan;

public sealed class CloudFormationScanResult
{
    public string Path { get; set; } = null!;

    public string Format { get; set; } = null!;

    public CloudFormationTemplateClassification Classification { get; set; }

    public IReadOnlyList<string> ResourceTypes { get; set; } = [];

    public IReadOnlyDictionary<string, object?> ParameterDefaults { get; set; } = new Dictionary<string, object?>();

    public IReadOnlyDictionary<string, object?> RawTemplate { get; set; } = new Dictionary<string, object?>();

    public string RawCfn { get; set; } = null!;
}
