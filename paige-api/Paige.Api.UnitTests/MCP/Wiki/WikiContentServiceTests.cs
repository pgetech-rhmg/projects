using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

using Paige.Api.MCP.Wiki.Models;
using Paige.Api.MCP.Wiki.Services;

using Xunit;

namespace Paige.Api.UnitTests.MCP.Wiki;

public sealed class WikiContentServiceTests
{
    // -------------------------------------------------------------------------
    // FetchAndChunkAsync - Full HTML flow
    // -------------------------------------------------------------------------

    [Fact]
    public async Task FetchAndChunkAsync_Should_Parse_RemoveNoise_Normalize_And_Chunk()
    {
        var html = @"
        <html>
            <head><style>noise</style></head>
            <body>
                <script>noise</script>
                <header>noise</header>

                <h1>Title</h1>

                <p>
                    Paragraph with
                    <a href=""/relative"">Link</a>
                </p>

                <a href="""">EmptyHref</a>
                <a href=""/only-url""></a>
                <a href=""http://external.com"">External</a>

                <div>   lots      of     whitespace   </div>

                <footer>noise</footer>
            </body>
        </html>";

        var client = CreateHttpClient(html);
        var service = new WikiContentService(client);

        var result = await service.FetchAndChunkAsync("test/page", CancellationToken.None);

        Assert.NotEmpty(result);

        var chunk = result[0];

        Assert.Equal(1, chunk.Index);
        Assert.True(chunk.CharacterCount > 0);

        var text = chunk.Text;

        // Heading uppercased
        Assert.Contains("TITLE", text);

        // Relative link expanded
        Assert.Contains("Link (https://wiki.comp.pge.com/test/page/relative)", text);

        // Empty href -> text only
        Assert.Contains("EmptyHref", text);

        // Empty link text -> url only
        Assert.Contains("/only-url", text);

        // Absolute link preserved
        Assert.Contains("External (http://external.com)", text);

        // Whitespace normalized
        Assert.DoesNotContain("      ", text);
    }

    // -------------------------------------------------------------------------
    // No noise nodes case
    // -------------------------------------------------------------------------

    [Fact]
    public async Task FetchAndChunkAsync_Should_Handle_No_NoiseNodes()
    {
        var html = "<html><body><p>Hello world</p></body></html>";

        var client = CreateHttpClient(html);
        var service = new WikiContentService(client);

        var result = await service.FetchAndChunkAsync("simple", CancellationToken.None);

        Assert.Single(result);
        Assert.Contains("Hello world", result[0].Text);
    }

    // -------------------------------------------------------------------------
    // Chunking - multi chunk
    // -------------------------------------------------------------------------

    [Fact]
    public async Task FetchAndChunkAsync_Should_Create_Multiple_Chunks_When_Large()
    {
        var largeText = new string('A', 160000); // 2 chunks (80k each)
        var html = $"<html><body><p>{largeText}</p></body></html>";

        var client = CreateHttpClient(html);
        var service = new WikiContentService(client);

        var result = await service.FetchAndChunkAsync("large", CancellationToken.None);

        Assert.Equal(2, result.Count);
        Assert.Equal(1, result[0].Index);
        Assert.Equal(2, result[1].Index);
        Assert.Equal(largeText.Length, result[0].CharacterCount);
        Assert.Equal(largeText.Length, result[1].CharacterCount);
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private static HttpClient CreateHttpClient(string response)
    {
        var handler = new FakeHttpMessageHandler(response);
        return new HttpClient(handler);
    }

    private sealed class FakeHttpMessageHandler : HttpMessageHandler
    {
        private readonly string _response;

        public FakeHttpMessageHandler(string response)
        {
            _response = response;
        }

        protected override Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request,
            CancellationToken cancellationToken)
        {
            var message = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(_response, Encoding.UTF8, "text/html")
            };

            return Task.FromResult(message);
        }
    }
}

