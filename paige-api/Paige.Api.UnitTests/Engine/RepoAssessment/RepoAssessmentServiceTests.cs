using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.Extensions.Options;

using Moq;

using Paige.Api.Engine.Common;
using Paige.Api.Engine.RepoAssessment;

using Xunit;

namespace Paige.Api.Tests.Engine.RepoAssessment;

public sealed class RepoAssessmentServiceTests
{
    // private readonly Mock<IRepoCloner> _repoClonerMock;
    // private readonly Mock<IFileScanner> _fileScannerMock;
    // private readonly Mock<IRepoStructureAnalyzer> _analyzerMock;

    // private readonly RepoAssessmentService _service;

    // private readonly Config _config;

    public RepoAssessmentServiceTests()
    {
        // _repoClonerMock = new Mock<IRepoCloner>();
        // _fileScannerMock = new Mock<IFileScanner>();
        // _analyzerMock = new Mock<IRepoStructureAnalyzer>();

        // _config = new Config
        // {
        //     GithubBaseUrl = "https://github.com"
        // };

        // var options = Options.Create(_config);

        // _service = new RepoAssessmentService(
        //     options,
        //     _repoClonerMock.Object,
        //     _fileScannerMock.Object,
        //     _analyzerMock.Object);
    }

    // [Fact]
    // public async Task ScanAsync_Should_Throw_When_Request_Is_Null()
    // {
    //     RepoAssessmentRequest request = null;

    //     await Assert.ThrowsAsync<ArgumentNullException>(() =>
    //         _service.ScanAsync(request!, CancellationToken.None));
    // }

    // [Fact]
    // public async Task ScanAsync_Should_Clone_Scan_Analyze_And_Return_Result()
    // {
    //     // Arrange
    //     var request = new RepoAssessmentRequest
    //     {
    //         RepoName = "test-repo",
    //         Branch = "main"
    //     };

    //     var cancellationToken = new CancellationTokenSource().Token;

    //     var clonedRepo = new ClonedRepo
    //     {
    //         LocalPath = "/tmp/test-repo",
    //         CommitSha = "abc123"
    //     };

    //     var scannedFiles = new List<ScannedFile>
    //     {
    //         new ScannedFile(),
    //         new ScannedFile(),
    //         new ScannedFile()
    //     };

    //     // Create RepoStructureSummary without knowing its constructor
    //     var structureSummary = (RepoStructureSummary)
    //         FormatterServices.GetUninitializedObject(typeof(RepoStructureSummary));

    //     _repoClonerMock
    //         .Setup(x => x.CloneAsync(
    //             "https://github.com/test-repo",
    //             "main",
    //             cancellationToken))
    //         .ReturnsAsync(clonedRepo);

    //     _fileScannerMock
    //         .Setup(x => x.Scan("/tmp/test-repo", true))
    //         .Returns(scannedFiles);

    //     _analyzerMock
    //         .Setup(x => x.Analyze("test-repo", "main", scannedFiles))
    //         .Returns(structureSummary);

    //     // Act
    //     var result = await _service.ScanAsync(request, cancellationToken);

    //     // Assert
    //     Assert.NotNull(result);

    //     Assert.NotNull(result.Repo);
    //     Assert.Equal("test-repo", result.Repo.RepoName);
    //     Assert.Equal("main", result.Repo.Branch);
    //     Assert.Equal("abc123", result.Repo.CommitSha);

    //     Assert.NotNull(result.Summary);
    //     Assert.Equal(3, result.Summary.FilesScanned);
    //     Assert.Equal(structureSummary, result.Summary.Structure);

    //     _repoClonerMock.Verify(x => x.CloneAsync(
    //         "https://github.com/test-repo",
    //         "main",
    //         cancellationToken), Times.Once);

    //     _fileScannerMock.Verify(x => x.Scan("/tmp/test-repo", true), Times.Once);

    //     _analyzerMock.Verify(x => x.Analyze(
    //         "test-repo",
    //         "main",
    //         scannedFiles), Times.Once);
    // }
}

