namespace Paige.Api.Engine.Mcp;

public interface IMcpClientService
{
	Task<string> SearchTerraformModulesAsync(string query, int limit, CancellationToken cancellationToken);
}