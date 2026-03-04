using System.Net.Http.Headers;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;

namespace Paige.Api.Engine.Mcp;

public interface IMcpClientService
{
	Task<string> SearchConfluenceAsync(string query, int limit, CancellationToken cancellationToken);
}
