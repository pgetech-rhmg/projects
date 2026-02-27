namespace Paige.Api.MCP.Wiki.Models;

public sealed class WikiChunk
{
    public int Index { get; set; }
    public string Text { get; set; } = string.Empty;
    public int CharacterCount { get; set; } = 0;
}
