using System.Collections.ObjectModel;
using System.Diagnostics;

namespace Paige.Api.Engine.Common;

public sealed class RepoCloner : IRepoCloner
{
    private const int GitProcessTimeoutSeconds = 300;

    public async Task<ClonedRepo> CloneAsync(
        string repoUrl,
        string branch,
        string githubToken,
        CancellationToken cancellationToken)
    {
        var workingDirectory = CreateWorkingDirectory();

        await ExecuteGitCloneAsync(
            repoUrl,
            branch,
            githubToken,
            workingDirectory,
            cancellationToken);

        var commitSha = await GetCommitShaAsync(
            workingDirectory,
            cancellationToken);

        return new ClonedRepo
        {
            LocalPath = workingDirectory,
            CommitSha = commitSha
        };
    }

    private static string CreateWorkingDirectory()
    {
        var basePath = Path.Combine(
            Path.GetTempPath(),
            "paige",
            "repos",
            Guid.NewGuid().ToString("N"));

        Directory.CreateDirectory(basePath);

        return basePath;
    }

    private static async Task ExecuteGitCloneAsync(
        string repoUrl,
        string branch,
        string githubToken,
        string targetDirectory,
        CancellationToken cancellationToken)
    {
        await ExecuteGitCommandAsync(
            args =>
            {
                args.Add("clone");
                args.Add("--depth");
                args.Add("1");
                args.Add("--branch");
                args.Add(branch);
                args.Add(repoUrl);
                args.Add(targetDirectory);
            },
            githubToken,
            cancellationToken);
    }

    private static async Task<string> GetCommitShaAsync(
        string workingDirectory,
        CancellationToken cancellationToken)
    {
        return (await ExecuteGitCommandAsync(
            args =>
            {
                args.Add("rev-parse");
                args.Add("HEAD");
            },
            null,
            cancellationToken,
            workingDirectory)).Trim();
    }

    private static async Task<string> ExecuteGitCommandAsync(
        Action<Collection<string>> configureArguments,
        string? githubToken,
        CancellationToken cancellationToken,
        string? workingDirectory = null)
    {
        var startInfo = new ProcessStartInfo
        {
            FileName = ResolveGitPath(),
            WorkingDirectory = workingDirectory ?? string.Empty,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        configureArguments(startInfo.ArgumentList);

        //
        // 🔐 Secure GitHub token injection
        //
        if (!string.IsNullOrWhiteSpace(githubToken))
        {
            startInfo.Environment["GIT_ASKPASS"] = ResolveAskPassScriptPath();
            startInfo.Environment["GITHUB_TOKEN"] = githubToken;
        }

        using var process = new Process
        {
            StartInfo = startInfo
        };

        process.Start();

        using var timeoutCts =
            CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);

        timeoutCts.CancelAfter(TimeSpan.FromSeconds(GitProcessTimeoutSeconds));

        var outputTask = process.StandardOutput.ReadToEndAsync();
        var errorTask = process.StandardError.ReadToEndAsync();

        var waitForExitTask = Task.Run(
            () => process.WaitForExit(),
            timeoutCts.Token);

        await Task.WhenAny(
            waitForExitTask,
            Task.Delay(Timeout.Infinite, timeoutCts.Token));

        if (!process.HasExited)
        {
            process.Kill(true);
            throw new InvalidOperationException("Git command timed out.");
        }

        var output = await outputTask;
        var error = await errorTask;

        if (process.ExitCode != 0)
        {
            throw new InvalidOperationException(
                $"Git command failed: {error}");
        }

        return output;
    }

    private static string ResolveGitPath()
    {
        var possiblePaths = new[]
        {
            "/usr/bin/git",
            "/usr/local/bin/git",
            @"C:\Program Files\Git\bin\git.exe"
        };

        foreach (var path in possiblePaths)
        {
            if (File.Exists(path))
            {
                return path;
            }
        }

        throw new InvalidOperationException("Git executable not found.");
    }

    //
    // Creates a temporary askpass script that echoes the token
    //
    private static string ResolveAskPassScriptPath()
    {
        var scriptPath = Path.Combine(
            Path.GetTempPath(),
            "paige_git_askpass.sh");

        if (!File.Exists(scriptPath))
        {
            File.WriteAllText(
                scriptPath,
                "#!/bin/sh\n" +
                "echo \"$GITHUB_TOKEN\"");

            if (!OperatingSystem.IsWindows())
            {
                Process.Start("chmod", $"+x {scriptPath}")?.WaitForExit();
            }
        }

        return scriptPath;
    }
}
