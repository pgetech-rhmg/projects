namespace Paige.Api.Engine.PortKey;

public interface IPortKeyExecutionService
{
    Task<PortKeyExecutionResult> ExecuteAsync(PortKeyPromptEnvelope prompt, CancellationToken cancellationToken);

    IAsyncEnumerable<string> ExecuteStreamAsync(PortKeyPromptEnvelope prompt, CancellationToken cancellationToken);
}
