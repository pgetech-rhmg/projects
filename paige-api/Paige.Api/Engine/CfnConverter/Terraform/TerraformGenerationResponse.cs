namespace Paige.Api.Engine.CfnConverter.Terraform;

public sealed class TerraformGenerationResponse
{
    public IDictionary<string, string> Files { get; init; } = new Dictionary<string, string>();
}

