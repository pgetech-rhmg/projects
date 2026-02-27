using System.Text.Json;

using Microsoft.Extensions.Options;

using Paige.Api.Engine.Common;
using Paige.Api.Engine.PortKey;

namespace Paige.Api.Packs;

public sealed class PackClassificationService : IPackClassificationService
{
    private readonly Config _config;
    private readonly IPortKeyExecutionService _portKeyExecutionService;
    private readonly IReadOnlyCollection<IContextPack> _allPacks;

    private static string BuildClassifierSystemPrompt(
        IReadOnlyList<string> domains,
        IReadOnlyList<string> topics)
    {
        return
    $"""
You are a routing and classification engine.

You do NOT answer the user.
You do NOT explain anything.

Your job is to examine the user's request and decide
which domains and topics apply, based on the routing options below.

{FormatList("Available domains", domains)}

{FormatList("Available topics", topics)}

Set requiresGovernance=true if the request involves:
- IAM, auth, identity, encryption
- security-sensitive configuration
- production infrastructure
- compliance or policy enforcement

Risk level guidance:
- low: conceptual or educational questions
- medium: implementation guidance
- high: production changes, security, identity, data access

Inference guidance:

If the request is vague or high-level, choose the closest matching
domains and topics rather than returning empty arrays.

Only return empty arrays if the request truly does not map
to any available domain or topic.

If uncertain, return empty arrays and conservative values.

If the request implies a procedural or instructional need,
add a short intent hint such as:
- "how-to"
- "setup"
- "troubleshooting"
- "deployment"
- "authentication"

Return a single JSON object matching this schema exactly:
{ClassificationJsonSchema}

Return JSON ONLY. No markdown. No prose.
""";
    }

    private const string ClassificationJsonSchema =
    """
{
  "domains": string[],
  "topics": string[],
  "riskLevel": "low" | "medium" | "high",
  "requiresGovernance": boolean,
  "intentHints": string[]
}
""";

    public PackClassificationService(
        IOptions<Config> config,
        IPortKeyExecutionService portKeyExecutionService,
        IReadOnlyCollection<IContextPack> allPacks)
    {
        _config = config.Value;
        _portKeyExecutionService = portKeyExecutionService;
        _allPacks = allPacks;
    }

    public async Task<PackClassificationResult> ClassifyAsync(string userPrompt, CancellationToken cancellationToken)
    {
        var domains =
            _allPacks
                .SelectMany(p => p.Metadata.Domains)
                .Where(d => !string.IsNullOrWhiteSpace(d))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(d => d)
                .ToList();

        var topics =
            _allPacks
                .SelectMany(p => p.Metadata.Topics)
                .Where(t => !string.IsNullOrWhiteSpace(t))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(t => t)
                .ToList();

        var systemPrompt = BuildClassifierSystemPrompt(domains, topics);

        var messages = new[]
        {
            new { role = "system", content = systemPrompt },
            new { role = "user", content = userPrompt }
        };

        // Use CHEAP model here (gpt-4o-mini, gpt-4.1-mini, etc)
        var rawResponse = await _portKeyExecutionService.ExecuteAsync(
            new PortKeyPromptEnvelope
            {
                Model = _config.PortKeyClassifierModel,
                Messages = messages,
                PromptKey = "classifier"
            },
            cancellationToken);

        try
        {
            PackClassificationResult classification = JsonSerializer.Deserialize<PackClassificationResult>(
                rawResponse.Output,
                new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                })!;

            Console.WriteLine("");
            Console.WriteLine("*** classification ***");
            Console.WriteLine(JsonSerializer.Serialize(classification));
            Console.WriteLine("");

            return classification;
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException("Pack classification returned invalid JSON.", ex);
        }
    }

    private static string FormatList(string title, IReadOnlyList<string> values)
    {
        if (values.Count == 0)
        {
            return $"{title}: (none)";
        }

        var lines = values.Select(v => $"- {v}");

        return $"{title}:{Environment.NewLine}{string.Join(Environment.NewLine, lines)}";
    }
}
