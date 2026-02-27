namespace Paige.Api.Packs;

public sealed class BaselinePackLoader
{
    private readonly IReadOnlyCollection<IContextPack> _allPacks;

    public BaselinePackLoader(IReadOnlyCollection<IContextPack> allPacks)
    {
        _allPacks = allPacks;
    }

    public IReadOnlyList<IContextPack> GetBaselinePacks()
    {
        return _allPacks
            .Where(p => p.Metadata.AlwaysInject)
            .OrderBy(p => p.Metadata.SafetyCritical)
            .ThenBy(p => p.Metadata.Priority)
            .ThenBy(p => p.Metadata.PackId)
            .ToList();
    }
}

