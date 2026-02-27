using System.Text.Json;

using YamlDotNet.RepresentationModel;

using Paige.Api.Engine.Common;

namespace Paige.Api.Engine.CfnConverter.Scan;

public static class CloudFormationTemplateLoader
{
    public static CloudFormationTemplate Load(ScannedFile file)
    {
        ArgumentNullException.ThrowIfNull(file);

        string extension = Path.GetExtension(file.FullPath);

        if (extension.Equals(".json", StringComparison.OrdinalIgnoreCase))
        {
            return LoadJson(file);
        }

        if (extension.Equals(".yaml", StringComparison.OrdinalIgnoreCase)
            || extension.Equals(".yml", StringComparison.OrdinalIgnoreCase))
        {
            return LoadYaml(file);
        }

        return new CloudFormationTemplate
        {
            Path = file.FullPath,
            Format = extension.TrimStart('.'),
            RawTemplate = new Dictionary<string, object?>()
        };
    }

    private static CloudFormationTemplate LoadJson(ScannedFile file)
    {
        string json = File.ReadAllText(file.FullPath);

        JsonElement root = JsonSerializer.Deserialize<JsonElement>(json);

        return new CloudFormationTemplate
        {
            Path = file.FullPath,
            Format = "json",
            RawTemplate = ConvertJsonElement(root),
            RawCfn = json
        };
    }

    private static CloudFormationTemplate LoadYaml(ScannedFile file)
    {
        try
        {
            string rawYaml = File.ReadAllText(file.FullPath);

            using var reader = new StringReader(rawYaml);

            var yaml = new YamlStream();

            yaml.Load(reader);

            if (yaml.Documents.Count == 0)
            {
                return EmptyTemplate(file, "yaml");
            }

            object? root = ConvertYamlNode(yaml.Documents[0].RootNode);

            return new CloudFormationTemplate
            {
                Path = file.FullPath,
                Format = "yaml",
                RawTemplate = root as Dictionary<string, object?> ?? [],
                RawCfn = rawYaml
            };
        }
        catch
        {
            return EmptyTemplate(file, "yaml");
        }
    }

    private static CloudFormationTemplate EmptyTemplate(ScannedFile file, string format)
    {
        return new CloudFormationTemplate
        {
            Path = file.FullPath,
            Format = format,
            RawTemplate = new Dictionary<string, object?>()
        };
    }

    private static object? ConvertYamlNode(YamlNode node)
    {
        switch (node)
        {
            case YamlMappingNode mapping:
                Dictionary<string, object?> map = new();

                foreach (var entry in mapping.Children)
                {
                    string key = ((YamlScalarNode)entry.Key).Value ?? string.Empty;
                    
                    map[key] = ConvertYamlNode(entry.Value);
                }

                return map;

            case YamlSequenceNode sequence:
                List<object?> list = [];

                foreach (YamlNode child in sequence.Children)
                {
                    list.Add(ConvertYamlNode(child));
                }

                return list;

            case YamlScalarNode scalar:
                return scalar.Value;

            default:
                return null;
        }
    }

    private static IReadOnlyDictionary<string, object?> ConvertJsonElement(JsonElement element)
    {
        Dictionary<string, object?> result = new();

        foreach (JsonProperty property in element.EnumerateObject())
        {
            result[property.Name] = property.Value.ValueKind switch
            {
                JsonValueKind.Object => ConvertJsonElement(property.Value),
                JsonValueKind.Array => property.Value,
                JsonValueKind.String => property.Value.GetString(),
                JsonValueKind.Number => property.Value.GetRawText(),
                JsonValueKind.True => true,
                JsonValueKind.False => false,
                _ => null
            };
        }

        return result;
    }
}
