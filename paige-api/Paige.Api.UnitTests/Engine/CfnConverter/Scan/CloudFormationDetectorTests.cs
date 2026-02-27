using Xunit;

using Paige.Api.Engine.CfnConverter.Scan;
using Paige.Api.Engine.Common;

namespace Paige.Api.Tests.Engine.CfnConverter.Scan;

public sealed class CloudFormationDetectorTests
{
    private readonly CloudFormationDetector _detector = new();

    // ============================================================
    // Null guard
    // ============================================================

    [Fact]
    public void IsCloudFormation_Throws_WhenFileIsNull()
    {
        Assert.Throws<ArgumentNullException>(() =>
            _detector.IsCloudFormation(null!));
    }

    // ============================================================
    // Unsupported extension
    // ============================================================

    [Fact]
    public void IsCloudFormation_ReturnsFalse_WhenExtensionUnsupported()
    {
        var file = new ScannedFile
        {
            FullPath = "test.txt"
        };

        Assert.False(_detector.IsCloudFormation(file));
    }

    // ============================================================
    // File read failure
    // ============================================================

    [Fact]
    public void IsCloudFormation_ReturnsFalse_WhenFileReadFails()
    {
        var file = new ScannedFile
        {
            FullPath = "missing.yaml"
        };

        Assert.False(_detector.IsCloudFormation(file));
    }

    // ============================================================
    // Empty content
    // ============================================================

    [Fact]
    public void IsCloudFormation_ReturnsFalse_WhenContentEmpty()
    {
        string path = CreateTempFile(".yaml", "   ");

        try
        {
            var file = new ScannedFile { FullPath = path };

            Assert.False(_detector.IsCloudFormation(file));
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // AWSTemplateFormatVersion signal
    // ============================================================

    [Fact]
    public void IsCloudFormation_ReturnsTrue_WhenAWSTemplateFormatVersionFound()
    {
        string path = CreateTempFile(".yaml", "AWSTemplateFormatVersion: 2010-09-09");

        try
        {
            var file = new ScannedFile { FullPath = path };

            Assert.True(_detector.IsCloudFormation(file));
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // Resources: signal (newline)
    // ============================================================

    [Fact]
    public void IsCloudFormation_ReturnsTrue_WhenResourcesSectionFound()
    {
        string path = CreateTempFile(".yaml", "\nResources:\n  MyBucket:");

        try
        {
            var file = new ScannedFile { FullPath = path };

            Assert.True(_detector.IsCloudFormation(file));
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // Resources: at start
    // ============================================================

    [Fact]
    public void IsCloudFormation_ReturnsTrue_WhenResourcesAtStart()
    {
        string path = CreateTempFile(".yaml", "Resources:\n  MyBucket:");

        try
        {
            var file = new ScannedFile { FullPath = path };

            Assert.True(_detector.IsCloudFormation(file));
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // YAML Type signal
    // ============================================================

    [Fact]
    public void IsCloudFormation_ReturnsTrue_WhenYamlTypeSignalFound()
    {
        string path = CreateTempFile(".yaml", "Type: AWS::S3::Bucket");

        try
        {
            var file = new ScannedFile { FullPath = path };

            Assert.True(_detector.IsCloudFormation(file));
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // JSON Type signal
    // ============================================================

    [Fact]
    public void IsCloudFormation_ReturnsTrue_WhenJsonTypeSignalFound()
    {
        string path = CreateTempFile(".json", "\"Type\": \"AWS::S3::Bucket\"");

        try
        {
            var file = new ScannedFile { FullPath = path };

            Assert.True(_detector.IsCloudFormation(file));
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // Intrinsic function signals
    // ============================================================

    [Theory]
    [InlineData("!Ref MyParam")]
    [InlineData("!Sub ${Value}")]
    [InlineData("Fn::GetAtt")]
    public void IsCloudFormation_ReturnsTrue_WhenIntrinsicSignalsFound(string content)
    {
        string path = CreateTempFile(".yaml", content);

        try
        {
            var file = new ScannedFile { FullPath = path };

            Assert.True(_detector.IsCloudFormation(file));
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // No signals
    // ============================================================

    [Fact]
    public void IsCloudFormation_ReturnsFalse_WhenNoSignalsFound()
    {
        string path = CreateTempFile(".yaml", "hello world");

        try
        {
            var file = new ScannedFile { FullPath = path };

            Assert.False(_detector.IsCloudFormation(file));
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // Helper
    // ============================================================

    private static string CreateTempFile(string extension, string content)
    {
        string path = Path.Combine(Path.GetTempPath(), Guid.NewGuid() + extension);
        File.WriteAllText(path, content);
        return path;
    }
}

