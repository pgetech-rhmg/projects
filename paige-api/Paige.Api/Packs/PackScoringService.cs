using System.Text.Json;

namespace Paige.Api.Packs;

public sealed class PackScoringService
{
    public IReadOnlyList<IContextPack> RankPacks(string userPrompt, PackClassificationResult classification, IReadOnlyCollection<IContextPack> packs)
    {
        var normalizedPrompt = userPrompt.ToLowerInvariant();

        var scored = new List<PackScore>();

        foreach (var pack in packs)
        {
            if (classification.RequiresGovernance && !pack.Metadata.SafetyCritical)
            {
                continue;
            }

            var score = 0;

            foreach (var keyword in pack.Metadata.Keywords)
            {
                if (normalizedPrompt.Contains(keyword.ToLowerInvariant()))
                {
                    score += 10;
                }
            }

            score += classification.Domains.Intersect(pack.Metadata.Domains, StringComparer.OrdinalIgnoreCase).Count() * 5;
            score += classification.Topics.Intersect(pack.Metadata.Topics, StringComparer.OrdinalIgnoreCase).Count() * 4;

            if (classification.IntentHints?.Any() == true)
            {
                score += classification.IntentHints.Intersect(pack.Metadata.Topics, StringComparer.OrdinalIgnoreCase).Count() * 3;
            }

            score += Math.Max(0, 10 - pack.Metadata.Priority);

            if (score > 0)
            {
                scored.Add(new PackScore
                {
                    Pack = pack,
                    Score = score
                });
            }
        }

        Console.WriteLine("*** scored ***");
        Console.WriteLine(JsonSerializer.Serialize(scored.OrderByDescending(s => s.Score).Select(s => new { s.Pack.Metadata.PackId, s.Score }).ToList()));
        Console.WriteLine("");

        return scored.OrderByDescending(s => s.Score).Select(s => s.Pack).ToList();
    }
}

