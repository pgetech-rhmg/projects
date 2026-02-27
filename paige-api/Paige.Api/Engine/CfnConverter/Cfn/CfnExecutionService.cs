using Paige.Api.Engine.PortKey;

namespace Paige.Api.Engine.CfnConverter.Cfn;

public sealed class CfnExecutionService
{
    private readonly IPortKeyExecutionService _portKeyExecutionService;

    public CfnExecutionService(IPortKeyExecutionService portKeyExecutionService)
    {
        _portKeyExecutionService = portKeyExecutionService;
    }

    public async Task<PortKeyExecutionResult> GenerateTerraformAsync(string rawCfn, CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(rawCfn))
        {
            throw new ArgumentNullException(nameof(rawCfn));
        }

        PortKeyPromptEnvelope prompt = CfnConversionPrompt.BuildPrompt(rawCfn);

        return await _portKeyExecutionService.ExecuteAsync(prompt, cancellationToken);
    }
}
