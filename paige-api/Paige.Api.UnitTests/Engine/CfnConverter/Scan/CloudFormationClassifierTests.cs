using Xunit;

using Paige.Api.Engine.CfnConverter.Scan;

namespace Paige.Api.Tests.Engine.CfnConverter.Scan;

public sealed class CloudFormationClassifierTests
{
    private readonly CloudFormationClassifier _classifier = new();

    // ============================================================
    // Null guard
    // ============================================================

    [Fact]
    public void Classify_Throws_WhenTemplateIsNull()
    {
        Assert.Throws<ArgumentNullException>(() =>
            _classifier.Classify(null!));
    }

    // ============================================================
    // Root (has Outputs)
    // ============================================================

    [Fact]
    public void Classify_ReturnsRoot_WhenOutputsExist()
    {
        var template = new CloudFormationTemplate
        {
            RawTemplate = new Dictionary<string, object?>
            {
                { "Outputs", new Dictionary<string, object?>() }
            }
        };

        var result = _classifier.Classify(template);

        Assert.Equal(CloudFormationTemplateClassification.Root, result);
    }

    // ============================================================
    // Nested (has Parameters, no Outputs)
    // ============================================================

    [Fact]
    public void Classify_ReturnsNested_WhenParametersExist_AndNoOutputs()
    {
        var template = new CloudFormationTemplate
        {
            RawTemplate = new Dictionary<string, object?>
            {
                { "Parameters", new Dictionary<string, object?>() }
            }
        };

        var result = _classifier.Classify(template);

        Assert.Equal(CloudFormationTemplateClassification.Nested, result);
    }

    // ============================================================
    // Partial (neither Outputs nor Parameters)
    // ============================================================

    [Fact]
    public void Classify_ReturnsPartial_WhenNoParametersOrOutputs()
    {
        var template = new CloudFormationTemplate
        {
            RawTemplate = new Dictionary<string, object?>()
        };

        var result = _classifier.Classify(template);

        Assert.Equal(CloudFormationTemplateClassification.Partial, result);
    }

    // ============================================================
    // Outputs takes precedence over Parameters
    // ============================================================

    [Fact]
    public void Classify_ReturnsRoot_WhenBothOutputsAndParametersExist()
    {
        var template = new CloudFormationTemplate
        {
            RawTemplate = new Dictionary<string, object?>
            {
                { "Parameters", new Dictionary<string, object?>() },
                { "Outputs", new Dictionary<string, object?>() }
            }
        };

        var result = _classifier.Classify(template);

        Assert.Equal(CloudFormationTemplateClassification.Root, result);
    }
}

