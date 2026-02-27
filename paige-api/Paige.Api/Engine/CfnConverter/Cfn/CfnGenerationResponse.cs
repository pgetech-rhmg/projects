using System.Text.Json;

namespace Paige.Api.Engine.CfnConverter.Cfn;

public sealed class CfnGenerationResponse
{
    public List<CfnResult> CfnResults { get; set; } = [];
}

public sealed class CfnResult
{
    public string Module { get; set; } = string.Empty;

    public JsonElement Files { get; set; }
}

