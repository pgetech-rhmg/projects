using System.Text.RegularExpressions;
using Paige.Api.Engine.Mcp;
using Paige.Api.Engine.PortKey;

namespace Paige.Api.Engine.CfnConverter.Cfn;

public sealed class CfnExecutionService
{
	private readonly IPortKeyExecutionService _portKeyExecutionService;
	private readonly IMcpClientService _mcpClientService;

	public CfnExecutionService(
		IPortKeyExecutionService portKeyExecutionService,
		IMcpClientService mcpClientService)
	{
		_portKeyExecutionService = portKeyExecutionService;
		_mcpClientService = mcpClientService;
	}

	public async Task<string> FetchStandardsAsync(HashSet<string> services, CancellationToken cancellationToken)
	{
		var query = services.Count > 0 
			? $"terraform {string.Join(" ", services)}"
			: "terraform";

		return await _mcpClientService.SearchConfluenceAsync(query, limit: 3, cancellationToken);
	}

	public async Task<PortKeyExecutionResult> GenerateTerraformAsync(string rawCfn, string standards, CancellationToken cancellationToken)
	{
		if (string.IsNullOrEmpty(rawCfn))
		{
			throw new ArgumentNullException(nameof(rawCfn));
		}

		var prompt = CfnConversionPrompt.BuildPrompt(rawCfn, standards);

		return await _portKeyExecutionService.ExecuteAsync(prompt, cancellationToken);
	}

	public static HashSet<string> ExtractAwsServices(string cfn)
	{
		var regex = new Regex(@"AWS::([A-Za-z0-9]+)::", RegexOptions.Compiled);
		var matches = regex.Matches(cfn);
		
		var services = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
		
		foreach (Match match in matches)
		{
			if (match.Groups.Count > 1)
			{
				services.Add(match.Groups[1].Value.ToLowerInvariant());
			}
		}

		return services;
	}
}