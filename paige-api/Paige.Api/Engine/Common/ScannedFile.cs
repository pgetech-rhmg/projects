namespace Paige.Api.Engine.Common;

public sealed class ScannedFile
{
    public string RelativePath { get; set; } = null!;

    public string FullPath { get; set; } = null!;

    public string Extension { get; set; } = "";

    public long SizeBytes { get; set; }

    public bool IsBinary { get; set; }

    /// <summary>
    /// SHA-256 of the file bytes (hex). Used for change detection / caching.
    /// </summary>
    public string Sha256 { get; set; } = "";

    /// <summary>
    /// File content if requested and if the file is detected as text and within size limits.
    /// Null otherwise.
    /// </summary>
    public string? Content { get; set; }

    /// <summary>
    /// Line count when content is captured. Null otherwise.
    /// </summary>
    public int? LineCount { get; set; }
}

