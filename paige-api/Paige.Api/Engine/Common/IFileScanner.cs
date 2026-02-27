namespace Paige.Api.Engine.Common;

public interface IFileScanner
{
    IReadOnlyList<ScannedFile> Scan(string rootPath, bool includeContent = false);
}

