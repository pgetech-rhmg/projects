using Xunit;

using Paige.Api.Engine.Common;

namespace Paige.Api.Tests.Engine.Common;

public sealed class FileScannerTests
{
    private readonly FileScanner _scanner = new();

    // ============================================================
    // Null / whitespace guard
    // ============================================================

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    public void Scan_ThrowsArgumentException_WhenRootInvalid(string? path)
    {
        Assert.Throws<ArgumentException>(() =>
            _scanner.Scan(path!));
    }

    // ============================================================
    // Directory not found
    // ============================================================

    [Fact]
    public void Scan_ThrowsDirectoryNotFound_WhenMissing()
    {
        string path = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());

        Assert.Throws<DirectoryNotFoundException>(() =>
            _scanner.Scan(path));
    }

    // ============================================================
    // Empty directory
    // ============================================================

    [Fact]
    public void Scan_ReturnsEmpty_WhenDirectoryEmpty()
    {
        string root = CreateTempDirectory();

        try
        {
            var result = _scanner.Scan(root);

            Assert.Empty(result);
        }
        finally
        {
            Directory.Delete(root, true);
        }
    }

    // ============================================================
    // Recursive scan + ignore .git
    // ============================================================

    [Fact]
    public void Scan_RecursivelyScans_AndIgnoresGit()
    {
        string root = CreateTempDirectory();

        try
        {
            // Create directories
            string subDir = Directory.CreateDirectory(Path.Combine(root, "sub")).FullName;
            string gitDir = Directory.CreateDirectory(Path.Combine(root, ".git")).FullName;

            // Create files
            string file1 = Path.Combine(root, "a.txt");
            string file2 = Path.Combine(subDir, "b.txt");
            string gitFile = Path.Combine(gitDir, "ignored.txt");

            File.WriteAllText(file1, "file1");
            File.WriteAllText(file2, "file2");
            File.WriteAllText(gitFile, "ignored");

            var result = _scanner.Scan(root);

            // Should include a.txt and sub/b.txt
            Assert.Equal(2, result.Count);

            Assert.Contains(result, f => f.RelativePath == "a.txt");
            Assert.Contains(result, f => f.RelativePath == "sub/b.txt");

            // Ensure .git file not included
            Assert.DoesNotContain(result, f => f.RelativePath.Contains(".git"));
        }
        finally
        {
            Directory.Delete(root, true);
        }
    }

    // ============================================================
    // includeContent = false
    // ============================================================

    [Fact]
    public void Scan_DoesNotIncludeContent_WhenFlagFalse()
    {
        string root = CreateTempDirectory();

        try
        {
            string file = Path.Combine(root, "file.txt");
            File.WriteAllText(file, "content");

            var result = _scanner.Scan(root, includeContent: false);

            var scanned = Assert.Single(result);

            Assert.Null(scanned.Content);
        }
        finally
        {
            Directory.Delete(root, true);
        }
    }

    // ============================================================
    // includeContent = true
    // ============================================================

    [Fact]
    public void Scan_IncludesContent_WhenFlagTrue()
    {
        string root = CreateTempDirectory();

        try
        {
            string file = Path.Combine(root, "file.txt");
            File.WriteAllText(file, "content");

            var result = _scanner.Scan(root, includeContent: true);

            var scanned = Assert.Single(result);

            Assert.Equal("content", scanned.Content);
        }
        finally
        {
            Directory.Delete(root, true);
        }
    }

    // ============================================================
    // Ordering by RelativePath (OrdinalIgnoreCase)
    // ============================================================

    [Fact]
    public void Scan_ReturnsFilesOrderedByRelativePath()
    {
        string root = CreateTempDirectory();

        try
        {
            File.WriteAllText(Path.Combine(root, "z.txt"), "z");
            File.WriteAllText(Path.Combine(root, "a.txt"), "a");

            var result = _scanner.Scan(root);

            Assert.Equal("a.txt", result[0].RelativePath);
            Assert.Equal("z.txt", result[1].RelativePath);
        }
        finally
        {
            Directory.Delete(root, true);
        }
    }

    // ============================================================
    // Path normalization (directory separator replaced with '/')
    // ============================================================

    [Fact]
    public void Scan_NormalizesRelativePathSeparators()
    {
        string root = CreateTempDirectory();

        try
        {
            string nested = Directory.CreateDirectory(Path.Combine(root, "nested")).FullName;
            string file = Path.Combine(nested, "file.txt");

            File.WriteAllText(file, "x");

            var result = _scanner.Scan(root);

            var scanned = Assert.Single(result);

            Assert.Equal("nested/file.txt", scanned.RelativePath);
        }
        finally
        {
            Directory.Delete(root, true);
        }
    }

    // ============================================================
    // Helper
    // ============================================================

    private static string CreateTempDirectory()
    {
        string path = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
        Directory.CreateDirectory(path);
        return path;
    }
}

