namespace Paige.Api.Engine.CfnConverter.Scan;

public sealed class CloudFormationTemplate
{
    public string Path { get; set; } = null!;

    public string Format { get; set; } = null!;

    public IReadOnlyDictionary<string, object?> RawTemplate { get; set; } = new Dictionary<string, object?>();

    public string RawCfn { get; set; } = null!;
}
