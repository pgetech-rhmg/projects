using System.Security.Cryptography;
using System.Text;

namespace Paige.Api.Engine.Common;

public sealed class FileScanner : IFileScanner
{
    private static readonly HashSet<string> IgnoredDirectories =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ".git",
            ".svn",
            ".hg",

            ".idea",
            ".vscode",

            "node_modules",
            "bower_components",

            "bin",
            "obj",
            "target",
            "out",
            "build",
            "dist",

            ".scannerwork",
            ".sonarqube",
            ".reports",
            "coverage",
            "TestResults",

            ".terraform",
            ".terragrunt-cache",
            ".pulumi",

            ".venv",
            "venv",
            "__pycache__",
            "site-packages"
        };

    // If includeContent=true, we will only load content up to this limit (bytes) for text files.
    // We still compute SizeBytes and Sha256 for all scanned files.
    private const long MaxContentBytes = 512 * 1024; // 512 KB

    // Binary detection reads up to this many bytes and checks for null bytes / invalid UTF-8 patterns.
    private const int BinaryProbeBytes = 8 * 1024; // 8 KB

    public IReadOnlyList<ScannedFile> Scan(string rootPath, bool includeContent = false)
    {
        if (string.IsNullOrWhiteSpace(rootPath))
        {
            throw new ArgumentException("Root path must be provided.", nameof(rootPath));
        }

        if (!Directory.Exists(rootPath))
        {
            throw new DirectoryNotFoundException($"Repository path not found: {rootPath}");
        }

        List<ScannedFile> results = [];

        ScanDirectory(
            rootPath,
            rootPath,
            includeContent,
            results);

        return [.. results.OrderBy(f => f.RelativePath, StringComparer.OrdinalIgnoreCase)];
    }

    private static void ScanDirectory(string rootPath, string currentPath, bool includeContent, List<ScannedFile> results)
    {
        foreach (string directory in Directory.GetDirectories(currentPath))
        {
            string directoryName = Path.GetFileName(directory);

            if (IgnoredDirectories.Contains(directoryName))
            {
                continue;
            }

            ScanDirectory(rootPath, directory, includeContent, results);
        }

        foreach (string file in Directory.GetFiles(currentPath))
        {
            string relativePath =
                Path.GetRelativePath(rootPath, file)
                    .Replace(Path.DirectorySeparatorChar, '/');

            FileInfo info = new(file);

            bool isBinary = IsBinaryFile(file);

            string sha256Hex = ComputeSha256Hex(file);

            var scanned = new ScannedFile
            {
                FullPath = file,
                RelativePath = relativePath,
                Extension = Path.GetExtension(relativePath),
                SizeBytes = info.Length,
                IsBinary = isBinary,
                Sha256 = sha256Hex,
                Content = null,
                LineCount = null
            };

            if (includeContent && !isBinary && info.Length <= MaxContentBytes)
            {
                string content = ReadAllTextUtf8OrFallback(file);

                scanned.Content = content;
                scanned.LineCount = CountLines(content);
            }

            if (scanned.Extension == null || scanned.Extension == "")
            {
                scanned.Extension = "[none]";
            }

            results.Add(scanned);
        }
    }

    private static bool IsBinaryFile(string filePath)
    {
        try
        {
            using FileStream stream = File.OpenRead(filePath);

            int toRead = (int)Math.Min(BinaryProbeBytes, stream.Length);
            if (toRead <= 0)
            {
                return false;
            }

            byte[] buffer = new byte[toRead];
            int read = stream.Read(buffer, 0, toRead);

            // Heuristic #1: Null byte indicates binary in most cases.
            for (int i = 0; i < read; i++)
            {
                if (buffer[i] == 0)
                {
                    return true;
                }
            }

            // Heuristic #2: Try strict UTF-8 decode. If it throws, treat as binary.
            try
            {
                _ = Encoding.UTF8.GetString(buffer, 0, read);
                return false;
            }
            catch
            {
                return true;
            }
        }
        catch
        {
            // If we cannot read the file, treat as binary to avoid downstream assumptions.
            return true;
        }
    }

    private static string ComputeSha256Hex(string filePath)
    {
        try
        {
            using FileStream stream = File.OpenRead(filePath);
            using SHA256 sha = SHA256.Create();

            byte[] hash = sha.ComputeHash(stream);

            return Convert.ToHexString(hash).ToLowerInvariant();
        }
        catch
        {
            return "";
        }
    }

    private static string ReadAllTextUtf8OrFallback(string filePath)
    {
        // UTF-8 first (most common), fallback to system default if needed.
        try
        {
            return File.ReadAllText(filePath, Encoding.UTF8);
        }
        catch
        {
            return File.ReadAllText(filePath);
        }
    }

    private static int CountLines(string content)
    {
        if (string.IsNullOrEmpty(content))
        {
            return 0;
        }

        int lines = 1;

        foreach (char c in content)
        {
            if (c == '\n')
            {
                lines++;
            }
        }

        return lines;
    }
}

