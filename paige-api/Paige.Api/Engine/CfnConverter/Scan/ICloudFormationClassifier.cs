namespace Paige.Api.Engine.CfnConverter.Scan;

public interface ICloudFormationClassifier
{
    CloudFormationTemplateClassification Classify(CloudFormationTemplate template);
}
