using System.Text.Json;
using Microsoft.Extensions.Options;
using Paige.Api.Engine.Common;

namespace Paige.Api.Engine.Mcp;

public sealed class McpClientService : IMcpClientService
{
	private readonly HttpClient _httpClient;
	private readonly string _baseUrl;

	public McpClientService(HttpClient httpClient, IOptions<Config> config)
	{
		_httpClient = httpClient;
		_baseUrl = config.Value.McpServerBaseUrl;
	}

	public async Task<string> SearchTerraformModulesAsync(string query, int limit, CancellationToken cancellationToken)
	{
		var url = $"{_baseUrl}/api/terraform/search?query={Uri.EscapeDataString(query)}&limit={limit}";
		
		var response = await _httpClient.PostAsync(url, null, cancellationToken);
		response.EnsureSuccessStatusCode();

		var json = await response.Content.ReadAsStringAsync(cancellationToken);
		
		using var doc = JsonDocument.Parse(json);
		
		if (doc.RootElement.TryGetProperty("content", out var content))
		{
			return content.GetString() ?? string.Empty;
		}

		return string.Empty;
	}
}