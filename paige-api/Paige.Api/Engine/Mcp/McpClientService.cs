using System.Net.Http.Headers;
using System.Runtime.CompilerServices;
using System.Text;
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

	public async Task<string> SearchConfluenceAsync(string query, int limit, CancellationToken cancellationToken)
	{
		var sessionId = Guid.NewGuid().ToString();
		
		// Initialize session
		var initPayload = new
		{
			jsonrpc = "2.0",
			id = 1,
			method = "initialize",
			@params = new
			{
				protocolVersion = "2024-11-05",
				capabilities = new { },
				clientInfo = new { name = "paige-cfn-converter", version = "1.0.0" }
			}
		};

		var initResponse = await PostMessageAsync(sessionId, initPayload, cancellationToken);
		
		// Call tool
		var toolPayload = new
		{
			jsonrpc = "2.0",
			id = 2,
			method = "tools/call",
			@params = new
			{
				name = "confluence_search",
				arguments = new
				{
					query = query,
					limit = limit,
					response_format = "markdown"
				}
			}
		};

		var toolResponse = await PostMessageAsync(sessionId, toolPayload, cancellationToken);

		using var doc = JsonDocument.Parse(toolResponse);
		
		if (doc.RootElement.TryGetProperty("result", out var result) &&
		    result.TryGetProperty("content", out var content) &&
		    content.GetArrayLength() > 0)
		{
			return content[0].GetProperty("text").GetString() ?? string.Empty;
		}

		return string.Empty;
	}

	private async Task<string> PostMessageAsync(string sessionId, object payload, CancellationToken cancellationToken)
	{
		var request = new HttpRequestMessage(HttpMethod.Post, $"{_baseUrl}/messages/{sessionId}")
		{
			Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json")
		};

		var response = await _httpClient.SendAsync(request, cancellationToken);
		response.EnsureSuccessStatusCode();

		return await response.Content.ReadAsStringAsync(cancellationToken);
	}
}