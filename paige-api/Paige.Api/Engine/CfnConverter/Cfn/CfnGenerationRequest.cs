namespace Paige.Api.Engine.CfnConverter.Cfn;

public sealed class CfnGenerationRequest
{
    public List<CfnInput> Cfns { get; set; } = [];
}

public sealed class CfnInput
{
    public string Module { get; set; } = string.Empty;

    public string RawCfn { get; set; } = string.Empty;
}

