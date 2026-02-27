using System.Text.Json;

namespace Paige.Api.Packs;

public static class ContextPackDiscovery
{
    public static IReadOnlyCollection<IContextPack> DiscoverAllPacks()
    {
        var packs = new List<IContextPack>();

        var basePath = Path.Combine(
            AppContext.BaseDirectory,
            "Packs/Context");

        if (!Directory.Exists(basePath))
        {
            return packs.AsReadOnly();
        }

        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        foreach (var file in Directory.GetFiles(basePath, "*.json", SearchOption.AllDirectories))
        {
            var json = File.ReadAllText(file);

            var dto = JsonSerializer.Deserialize<ContextPackDto>(json, options);

            if (dto?.Metadata == null || string.IsNullOrWhiteSpace(dto.Prompt))
            {
                continue;
            }

            packs.Add(new JsonContextPack(dto.Metadata, dto.Prompt));
        }

        return packs.AsReadOnly();
    }
}

