using Xunit;

using Paige.Api.Engine.Common;

namespace Paige.Api.Tests.Engine.Common;

public sealed class RepoClonerTests
{
    private readonly RepoCloner _cloner = new();

    // ============================================================
    // Success path
    // ============================================================

    [Fact]
    public async Task CloneAsync_ClonesLocalRepo_AndReturnsCommitSha()
    {
        string sourceRepo = CreateLocalGitRepo();

        try
        {
            var result = await _cloner.CloneAsync(sourceRepo, "main", CancellationToken.None);

            Assert.True(Directory.Exists(result.LocalPath));
            Assert.False(string.IsNullOrWhiteSpace(result.CommitSha));
        }
        finally
        {
            Directory.Delete(sourceRepo, true);
        }
    }

    // ============================================================
    // ExitCode != 0 branch
    // ============================================================

    [Fact]
    public async Task CloneAsync_Throws_WhenRepoInvalid()
    {
        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            _cloner.CloneAsync("https://invalid.invalid/repo.git", "main", CancellationToken.None));
    }

    // ============================================================
    // Timeout branch
    // ============================================================

    [Fact]
    public async Task CloneAsync_Throws_WhenCancelled()
    {
        using var cts = new CancellationTokenSource();
        cts.Cancel();

        await Assert.ThrowsAnyAsync<InvalidOperationException>(() =>
            _cloner.CloneAsync("https://github.com/git/git", "main", cts.Token));
    }

    // ============================================================
    // Helper: create local git repo
    // ============================================================

    private static string CreateLocalGitRepo()
    {
        string repoPath = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
        Directory.CreateDirectory(repoPath);

        RunGit("init -b main", repoPath);

        // Configure identity locally for this test repo
        RunGit("config user.email \"test@example.com\"", repoPath);
        RunGit("config user.name \"Test User\"", repoPath);

        File.WriteAllText(Path.Combine(repoPath, "file.txt"), "content");

        RunGit("add .", repoPath);
        RunGit("commit -m \"initial\"", repoPath);

        return repoPath;
    }

    private static void RunGit(string arguments, string workingDirectory)
    {
        var process = new System.Diagnostics.Process
        {
            StartInfo = new System.Diagnostics.ProcessStartInfo
            {
                FileName = "git",
                Arguments = arguments,
                WorkingDirectory = workingDirectory,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false
            }
        };

        process.Start();
        process.WaitForExit();

        if (process.ExitCode != 0)
        {
            string error = process.StandardError.ReadToEnd();
            throw new InvalidOperationException($"Git setup failed: {error}");
        }
    }
}

