using Microsoft.Extensions.Options;

using Moq;
using Xunit;

using Paige.Api.Engine.CfnConverter.Scan;
using Paige.Api.Engine.Common;

namespace Paige.Api.Tests.Engine.CfnConverter.Scan;

public sealed class RepoScanServiceTests
{
    private readonly Mock<IRepoCloner> _repoClonerMock = new(MockBehavior.Strict);
    private readonly Mock<IFileScanner> _fileScannerMock = new(MockBehavior.Strict);
    private readonly Mock<ICloudFormationDetector> _detectorMock = new(MockBehavior.Strict);
    private readonly Mock<ICloudFormationClassifier> _classifierMock = new(MockBehavior.Strict);

    private RepoScanService CreateService(string tempDir)
    {
        var config = Options.Create(new Config
        {
            GithubBaseUrl = "https://github.com"
        });

        return new RepoScanService(
            config,
            _repoClonerMock.Object,
            _fileScannerMock.Object,
            _detectorMock.Object,
            _classifierMock.Object);
    }

    // ============================================================
    // Null guard
    // ============================================================

    [Fact]
    public async Task ScanAsync_Throws_WhenRequestNull()
    {
        var service = CreateService(Path.GetTempPath());

        await Assert.ThrowsAsync<ArgumentNullException>(() =>
            service.ScanAsync(null!, CancellationToken.None));
    }

    // ============================================================
    // Full flow coverage
    // ============================================================

    [Fact]
    public async Task ScanAsync_CoversAllBranches()
    {
        string tempDir = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
        Directory.CreateDirectory(tempDir);

        try
        {
            // --------------------------------------------------------
            // Create template WITHOUT Resources (should be skipped)
            // --------------------------------------------------------
            string noResourcesPath = Path.Combine(tempDir, "noresources.json");
            await File.WriteAllTextAsync(noResourcesPath, """
            {
              "Parameters": {
                "Param1": {
                  "Type": "String"
                }
              }
            }
            """);

            // --------------------------------------------------------
            // Create valid template WITH Resources + Parameters
            // --------------------------------------------------------
            string validPath = Path.Combine(tempDir, "valid.json");
            await File.WriteAllTextAsync(validPath, """
            {
              "Resources": {
                "MyBucket": {
                  "Type": "AWS::S3::Bucket"
                },
                "MyTopic": {
                  "Type": "AWS::SNS::Topic"
                }
              },
              "Parameters": {
                "ParamA": {
                  "Type": "String",
                  "Default": "valueA"
                },
                "ParamB": {
                  "Type": "Number"
                }
              }
            }
            """);

            // --------------------------------------------------------
            // Setup mocks
            // --------------------------------------------------------

            _repoClonerMock
                .Setup(x => x.CloneAsync(
                    "https://github.com/test/repo",
                    "main",
                    It.IsAny<CancellationToken>()))
                .ReturnsAsync(new ClonedRepo
                {
                    LocalPath = tempDir,
                    CommitSha = "abc123"
                });

            var scannedFiles = new List<ScannedFile>
            {
                new ScannedFile
                {
                    FullPath = noResourcesPath,
                    RelativePath = "noresources.json"
                },
                new ScannedFile
                {
                    FullPath = validPath,
                    RelativePath = "valid.json"
                }
            };

            _fileScannerMock
                .Setup(x => x.Scan(tempDir))
                .Returns(scannedFiles);

            // First file: treat as CFN but skipped (no Resources)
            _detectorMock
                .Setup(x => x.IsCloudFormation(It.Is<ScannedFile>(f => f.FullPath == noResourcesPath)))
                .Returns(true);

            // Second file: valid CFN
            _detectorMock
                .Setup(x => x.IsCloudFormation(It.Is<ScannedFile>(f => f.FullPath == validPath)))
                .Returns(true);

            _classifierMock
                .Setup(x => x.Classify(It.IsAny<CloudFormationTemplate>()))
                .Returns(new CloudFormationTemplateClassification());

            var service = CreateService(tempDir);

            var request = new RepoScanRequest
            {
                RepoName = "test/repo",
                Branch = "main"
            };

            // --------------------------------------------------------
            // Act
            // --------------------------------------------------------
            RepoScanResult result = await service.ScanAsync(request, CancellationToken.None);

            // --------------------------------------------------------
            // Assert metadata
            // --------------------------------------------------------
            Assert.Equal("test/repo", result.Repo.RepoName);
            Assert.Equal("main", result.Repo.Branch);
            Assert.Equal("abc123", result.Repo.CommitSha);

            // --------------------------------------------------------
            // Assert summary
            // --------------------------------------------------------
            Assert.Equal(2, result.Summary.FilesScanned);
            Assert.Equal(1, result.Summary.CloudFormationFilesDetected);
            Assert.Equal(0, result.Summary.TerraformResourcesGenerated);

            // --------------------------------------------------------
            // Assert extracted data
            // --------------------------------------------------------
            var cfnFile = Assert.Single(result.CloudFormationFiles);

            Assert.Equal("valid.json", cfnFile.Path);

            // Resource types sorted
            Assert.Equal(
                new[] { "AWS::S3::Bucket", "AWS::SNS::Topic" },
                cfnFile.ResourceTypes);

            // Parameter defaults
            Assert.Single(cfnFile.ParameterDefaults);
            Assert.Equal("valueA", cfnFile.ParameterDefaults["ParamA"]);

            // Raw template preserved
            Assert.True(cfnFile.RawTemplate.ContainsKey("Resources"));
            Assert.True(cfnFile.RawTemplate.ContainsKey("Parameters"));

            _repoClonerMock.VerifyAll();
            _fileScannerMock.VerifyAll();
            _detectorMock.VerifyAll();
            _classifierMock.VerifyAll();
        }
        finally
        {
            Directory.Delete(tempDir, true);
        }
    }

    // ============================================================
    // Detector false branch
    // ============================================================

    [Fact]
    public async Task ScanAsync_Skips_WhenDetectorReturnsFalse()
    {
        string tempDir = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
        Directory.CreateDirectory(tempDir);

        try
        {
            string filePath = Path.Combine(tempDir, "file.txt");
            await File.WriteAllTextAsync(filePath, "not cfn");

            _repoClonerMock
                .Setup(x => x.CloneAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<CancellationToken>()))
                .ReturnsAsync(new ClonedRepo
                {
                    LocalPath = tempDir,
                    CommitSha = "sha"
                });

            _fileScannerMock
                .Setup(x => x.Scan(tempDir))
                .Returns(new List<ScannedFile>
                {
                    new ScannedFile
                    {
                        FullPath = filePath,
                        RelativePath = "file.txt"
                    }
                });

            _detectorMock
                .Setup(x => x.IsCloudFormation(It.IsAny<ScannedFile>()))
                .Returns(false);

            var service = CreateService(tempDir);

            var result = await service.ScanAsync(
                new RepoScanRequest { RepoName = "x", Branch = "main" },
                CancellationToken.None);

            Assert.Empty(result.CloudFormationFiles);
            Assert.Equal(1, result.Summary.FilesScanned);
            Assert.Equal(0, result.Summary.CloudFormationFilesDetected);

            _detectorMock.VerifyAll();
        }
        finally
        {
            Directory.Delete(tempDir, true);
        }
    }
}

