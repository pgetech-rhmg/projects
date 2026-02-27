namespace Paige.Api.MCP.Wiki.Models;

public sealed class WikiMcpResponse
{
    public string SourceUrl { get; set; } = string.Empty;
    public IReadOnlyList<WikiChunk> Chunks { get; set; } = [];
}
