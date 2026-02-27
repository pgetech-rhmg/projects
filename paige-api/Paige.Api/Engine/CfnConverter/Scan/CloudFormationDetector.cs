using Paige.Api.Engine.Common;

namespace Paige.Api.Engine.CfnConverter.Scan;

public sealed class CloudFormationDetector : ICloudFormationDetector
{
    public bool IsCloudFormation(ScannedFile file)
    {
        ArgumentNullException.ThrowIfNull(file);

        if (!IsSupportedExtension(file.FullPath))
        {
            return false;
        }

        string content;

        try
        {
            content = File.ReadAllText(file.FullPath);
        }
        catch
        {
            return false;
        }

        return ContainsCloudFormationSignals(content);
    }

    private static bool IsSupportedExtension(string filePath)
    {
        string extension = Path.GetExtension(filePath);

        return extension.Equals(".yaml", StringComparison.OrdinalIgnoreCase)
            || extension.Equals(".yml", StringComparison.OrdinalIgnoreCase)
            || extension.Equals(".json", StringComparison.OrdinalIgnoreCase);
    }

    private static bool ContainsCloudFormationSignals(string content)
    {
        if (string.IsNullOrWhiteSpace(content))
        {
            return false;
        }

        if (content.Contains("AWSTemplateFormatVersion", StringComparison.Ordinal))
        {
            return true;
        }

        if (content.Contains("\nResources:", StringComparison.Ordinal)
            || content.StartsWith("Resources:", StringComparison.Ordinal))
        {
            return true;
        }

        if (content.Contains("Type: AWS::", StringComparison.Ordinal))
        {
            return true;
        }

        if (content.Contains("\"Type\": \"AWS::", StringComparison.Ordinal))
        {
            return true;
        }

        if (content.Contains("!Ref", StringComparison.Ordinal)
            || content.Contains("!Sub", StringComparison.Ordinal)
            || content.Contains("Fn::", StringComparison.Ordinal))
        {
            return true;
        }

        return false;
    }
}
