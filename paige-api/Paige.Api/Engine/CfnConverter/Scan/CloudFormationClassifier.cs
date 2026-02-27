namespace Paige.Api.Engine.CfnConverter.Scan;

public sealed class CloudFormationClassifier : ICloudFormationClassifier
{
    public CloudFormationTemplateClassification Classify(CloudFormationTemplate template)
    {
        ArgumentNullException.ThrowIfNull(template);

        IReadOnlyDictionary<string, object?> document = template.RawTemplate;

        bool hasParameters = document.ContainsKey("Parameters");
        bool hasOutputs = document.ContainsKey("Outputs");

        if (hasOutputs)
        {
            return CloudFormationTemplateClassification.Root;
        }

        if (hasParameters)
        {
            return CloudFormationTemplateClassification.Nested;
        }

        return CloudFormationTemplateClassification.Partial;
    }
}
