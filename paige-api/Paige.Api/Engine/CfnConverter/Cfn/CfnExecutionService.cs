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

	public async Task<PortKeyExecutionResult> GenerateTerraformAsync(string rawCfn, CancellationToken cancellationToken)
	{
		if (string.IsNullOrEmpty(rawCfn))
		{
			throw new ArgumentNullException(nameof(rawCfn));
		}

		// Extract AWS service names from CFN template
		var services = ExtractAwsServices(rawCfn);
		var query = services.Count > 0 
			? $"terraform {string.Join(" ", services)}"
			: "terraform";

		// Fetch PG&E standards from MCP server
		var standards = await _mcpClientService.SearchConfluenceAsync(query, limit: 3, cancellationToken);

		// Build prompt with injected standards
		var prompt = CfnConversionPrompt.BuildPrompt(rawCfn, standards);

		return await _portKeyExecutionService.ExecuteAsync(prompt, cancellationToken);
	}

	private static HashSet<string> ExtractAwsServices(string cfn)
	{
		// Match patterns like AWS::Lambda::Function, AWS::S3::Bucket, etc.
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