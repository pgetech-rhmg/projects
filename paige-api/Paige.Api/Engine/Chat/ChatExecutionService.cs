using System.Runtime.CompilerServices;

using Paige.Api.Engine.PortKey;
using Paige.Api.Packs;

namespace Paige.Api.Engine.Chat;

public sealed class ChatExecutionService
{
    private readonly IReadOnlyCollection<IContextPack> _allPacks;
    private readonly IPortKeyExecutionService _portKeyExecutionService;
    private readonly BaselinePromptProvider _baselinePromptProvider;
    private readonly IPackClassificationService _packClassificationService;
    private readonly PackScoringService _packScoringService;

    public ChatExecutionService(
        IReadOnlyCollection<IContextPack> allPacks,
        IPortKeyExecutionService portKeyExecutionService,
        BaselinePromptProvider baselinePromptProvider,
        IPackClassificationService packClassificationService,
        PackScoringService packScoringService)
    {
        _allPacks = allPacks;
        _portKeyExecutionService = portKeyExecutionService;
        _baselinePromptProvider = baselinePromptProvider;
        _packClassificationService = packClassificationService;
        _packScoringService = packScoringService;
    }

    // ------------------------------------------------------------
    // NON-STREAMING
    // ------------------------------------------------------------
    public async Task<PortKeyExecutionResult> SendMessageAsync(ChatRequest request, CancellationToken cancellationToken)
    {
        ValidateRequest(request);

        var prompt = ChatConversionPrompt.BuildPrompt(_baselinePromptProvider.SystemPrompt, string.Empty, request);

        return await _portKeyExecutionService.ExecuteAsync(prompt, cancellationToken);
    }

    // ------------------------------------------------------------
    // STREAMING
    // ------------------------------------------------------------
    public async IAsyncEnumerable<string> SendMessageStreamAsync(ChatRequest request, [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        ValidateRequest(request);

        var classification = await _packClassificationService.ClassifyAsync(request.Prompt, cancellationToken);

        var contextPrompt = string.Empty;

        if (classification.Domains.Length > 0 || classification.Topics.Length > 0 || classification.IntentHints.Length > 0)
        {
            var packsToInclude = _packScoringService.RankPacks(request.Prompt, classification, _allPacks);

            // For multiple packs, remove the [0] from packs.
            List<string> packs = [.. packsToInclude.Select(p => p.Prompt)];

            contextPrompt = packs.Count == 0
                ? string.Empty
                : string.Join(Environment.NewLine + Environment.NewLine,
                    packs[0]);

        }

        var prompt = ChatConversionPrompt.BuildPrompt(_baselinePromptProvider.SystemPrompt, contextPrompt, request);

        await foreach (var chunk in _portKeyExecutionService.ExecuteStreamAsync(prompt, cancellationToken))
        {
            yield return chunk;
        }
    }

    // ------------------------------------------------------------
    // Guardrails
    // ------------------------------------------------------------
    private static void ValidateRequest(ChatRequest request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.Prompt))
        {
            throw new ArgumentNullException(nameof(request));
        }
    }
}

