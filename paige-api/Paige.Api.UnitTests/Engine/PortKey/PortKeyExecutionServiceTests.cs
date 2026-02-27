using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.Json;

using Microsoft.Extensions.Options;

using Xunit;

using Paige.Api.Engine.Common;
using Paige.Api.Engine.PortKey;

namespace Paige.Api.Tests.Engine.PortKey;

public sealed class PortKeyExecutionServiceTests
{
    // ============================================================
    // Constructor wiring
    // ============================================================

    [Fact]
    public void Constructor_ConfiguresHttpClient()
    {
        var handler = new FakeHandler(_ => new HttpResponseMessage(HttpStatusCode.OK));
        var client = new HttpClient(handler);

        var config = Options.Create(new Config
        {
            PortKeyBaseUrl = "https://example.com/",
            PortKeyApiKey = "key",
            PortKeyDefaultModel = "default"
        });

        var service = new PortKeyExecutionService(client, config);

        Assert.Equal(new Uri("https://example.com/"), client.BaseAddress);
        Assert.Equal("Bearer", client.DefaultRequestHeaders.Authorization!.Scheme);
        Assert.Equal("key", client.DefaultRequestHeaders.Authorization!.Parameter);
        Assert.True(client.DefaultRequestHeaders.Contains("X-Portkey-Mode"));
        Assert.True(client.DefaultRequestHeaders.Contains("X-Portkey-Strict"));
    }

    // ============================================================
    // ExecuteAsync success
    // ============================================================

    [Fact]
    public async Task ExecuteAsync_ReturnsParsedResult()
    {
        var json = """
        {
          "choices": [
            {
              "message": {
                "content": "hello world"
              }
            }
          ]
        }
        """;

        var handler = new FakeHandler(_ =>
            new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json")
            });

        var client = new HttpClient(handler);

        var config = Options.Create(new Config
        {
            PortKeyBaseUrl = "https://x/",
            PortKeyApiKey = "key",
            PortKeyDefaultModel = "model-a"
        });

        var service = new PortKeyExecutionService(client, config);

        var prompt = new PortKeyPromptEnvelope
        {
            Messages = new[] { new { role = "user", content = "hi" } }
        };

        var result = await service.ExecuteAsync(prompt, CancellationToken.None);

        Assert.Equal("hello world", result.Output);
        Assert.Equal("model-a", result.ModelAlias);
    }

    // ============================================================
    // ExecuteAsync model override
    // ============================================================

    [Fact]
    public async Task ExecuteAsync_UsesOverrideModel()
    {
        var handler = new FakeHandler(req =>
        {
            var body = req.Content!.ReadAsStringAsync().Result;

            Assert.Contains("\"model\":\"override\"", body);

            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent("""
                { "choices":[{"message":{"content":"x"}}] }
                """)
            };
        });

        var client = new HttpClient(handler);

        var config = Options.Create(new Config
        {
            PortKeyBaseUrl = "https://x/",
            PortKeyApiKey = "key",
            PortKeyDefaultModel = "default"
        });

        var service = new PortKeyExecutionService(client, config);

        var prompt = new PortKeyPromptEnvelope
        {
            Model = "override",
            Messages = new[] { new { role = "user", content = "hi" } }
        };

        await service.ExecuteAsync(prompt, CancellationToken.None);
    }

    // ============================================================
    // ExecuteAsync failure status
    // ============================================================

    [Fact]
    public async Task ExecuteAsync_Throws_WhenHttpFails()
    {
        var handler = new FakeHandler(_ =>
            new HttpResponseMessage(HttpStatusCode.BadRequest));

        var client = new HttpClient(handler);

        var config = Options.Create(new Config
        {
            PortKeyBaseUrl = "https://x/",
            PortKeyApiKey = "key",
            PortKeyDefaultModel = "model"
        });

        var service = new PortKeyExecutionService(client, config);

        await Assert.ThrowsAsync<HttpRequestException>(() =>
            service.ExecuteAsync(new PortKeyPromptEnvelope
            {
                Messages = Array.Empty<object>()
            }, CancellationToken.None));
    }

    // ============================================================
    // Streaming success path
    // ============================================================

    [Fact]
    public async Task ExecuteStreamAsync_StreamsContent()
    {
        var streamData = """
        not-data-line
        data: {"choices":[{"delta":{"content":"A"}}]}
        data: {"choices":[{"delta":{"content":""}}]}
        data: {"choices":[{"delta":{}}]}
        data: [DONE]
        """;

        var handler = new FakeHandler(_ =>
            new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(streamData)
            });

        var client = new HttpClient(handler);

        var config = Options.Create(new Config
        {
            PortKeyBaseUrl = "https://x/",
            PortKeyApiKey = "key",
            PortKeyDefaultModel = "model"
        });

        var service = new PortKeyExecutionService(client, config);

        var prompt = new PortKeyPromptEnvelope
        {
            Messages = Array.Empty<object>()
        };

        var results = new List<string>();

        await foreach (var chunk in service.ExecuteStreamAsync(prompt, CancellationToken.None))
        {
            results.Add(chunk);
        }

        Assert.Single(results);
        Assert.Equal("A", results[0]);
    }

    // ============================================================
    // Streaming cancellation
    // ============================================================

    [Fact]
    public async Task ExecuteStreamAsync_RespectsCancellation()
    {
        var streamData = "data: {\"choices\":[{\"delta\":{\"content\":\"X\"}}]}";

        var handler = new FakeHandler(_ =>
            new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(streamData)
            });

        var client = new HttpClient(handler);

        var config = Options.Create(new Config
        {
            PortKeyBaseUrl = "https://x/",
            PortKeyApiKey = "key",
            PortKeyDefaultModel = "model"
        });

        var service = new PortKeyExecutionService(client, config);

        using var cts = new CancellationTokenSource();
        cts.Cancel();

        await foreach (var _ in service.ExecuteStreamAsync(
            new PortKeyPromptEnvelope { Messages = Array.Empty<object>() },
            cts.Token))
        {
        }
    }

    // ============================================================
    // Null guards
    // ============================================================

    [Fact]
    public async Task ExecuteAsync_Throws_WhenPromptNull()
    {
        var service = CreateService();

        await Assert.ThrowsAsync<ArgumentNullException>(() =>
            service.ExecuteAsync(null!, CancellationToken.None));
    }

    [Fact]
    public async Task ExecuteStreamAsync_Throws_WhenPromptNull()
    {
        var service = CreateService();

        await Assert.ThrowsAsync<ArgumentNullException>(async () =>
        {
            await foreach (var _ in service.ExecuteStreamAsync(null!, CancellationToken.None))
            {
            }
        });
    }

    // ============================================================
    // Helpers
    // ============================================================

    private static PortKeyExecutionService CreateService()
    {
        var handler = new FakeHandler(_ => new HttpResponseMessage(HttpStatusCode.OK));
        var client = new HttpClient(handler);

        var config = Options.Create(new Config
        {
            PortKeyBaseUrl = "https://x/",
            PortKeyApiKey = "key",
            PortKeyDefaultModel = "model"
        });

        return new PortKeyExecutionService(client, config);
    }

    private sealed class FakeHandler : HttpMessageHandler
    {
        private readonly Func<HttpRequestMessage, HttpResponseMessage> _handler;

        public FakeHandler(Func<HttpRequestMessage, HttpResponseMessage> handler)
        {
            _handler = handler;
        }

        protected override Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request,
            CancellationToken cancellationToken)
        {
            return Task.FromResult(_handler(request));
        }
    }
}

