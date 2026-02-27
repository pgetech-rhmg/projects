using Paige.Api.MCP.Wiki.Models;

namespace Paige.Api.MCP.Wiki.Services;

public interface IWikiContentService
{
    Task<IReadOnlyList<WikiChunk>> FetchAndChunkAsync(
        string page,
        CancellationToken cancellationToken);
}

