namespace Paige.Api.Packs;

public interface IPackClassificationService
{
    Task<PackClassificationResult> ClassifyAsync(string userPrompt, CancellationToken cancellationToken);
}