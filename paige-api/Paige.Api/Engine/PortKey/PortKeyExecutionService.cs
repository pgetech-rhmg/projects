using System.Net.Http.Headers;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.Json;

using Microsoft.Extensions.Options;

using Paige.Api.Engine.Common;

namespace Paige.Api.Engine.PortKey;

public sealed class PortKeyExecutionService : IPortKeyExecutionService
{
    private readonly HttpClient _httpClient;
    private readonly Config _config;

    public PortKeyExecutionService(
        HttpClient httpClient,
        IOptions<Config> config)
    {
        _httpClient = httpClient;
        _config = config.Value;

        _httpClient.BaseAddress = new Uri(_config.PortKeyBaseUrl);
        _httpClient.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", _config.PortKeyApiKey);

        _httpClient.DefaultRequestHeaders.Add(
            "X-Portkey-Mode",
            "chat-completions");

        _httpClient.DefaultRequestHeaders.Add(
            "X-Portkey-Strict",
            "true");
    }

    // ------------------------------------------------------------
    // NON-STREAMING
    // ------------------------------------------------------------
    public async Task<PortKeyExecutionResult> ExecuteAsync(PortKeyPromptEnvelope prompt, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(prompt);

        var model = _config.PortKeyDefaultModel;

        if (prompt.Model != null)
        {
            model = prompt.Model;
        }

        var payload = new
        {
            model = model,
            temperature = 0,
            presence_penalty = 0,
            frequency_penalty = 0,
            messages = prompt.Messages
        };

        var request = new HttpRequestMessage(HttpMethod.Post, "v1/chat/completions")
        {
            Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json")
        };

        var response = await _httpClient.SendAsync(request, cancellationToken);

        response.EnsureSuccessStatusCode();

        using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));

        var content =
            doc.RootElement
               .GetProperty("choices")[0]
               .GetProperty("message")
               .GetProperty("content")
               .GetString()!;

        return new PortKeyExecutionResult
        {
            Output = content,
            ModelAlias = model,
            InputTokens = 0,
            OutputTokens = 0
        };
    }

    // ------------------------------------------------------------
    // STREAMING
    // ------------------------------------------------------------
    public async IAsyncEnumerable<string> ExecuteStreamAsync(PortKeyPromptEnvelope prompt, [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(prompt);

        var model = _config.PortKeyDefaultModel;

        if (prompt.Model != null)
        {
            model = prompt.Model;
        }

        var payload = new
        {
            model = model,
            stream = true,
            temperature = 0,
            presence_penalty = 0,
            frequency_penalty = 0,
            messages = prompt.Messages
        };

        var request = new HttpRequestMessage(HttpMethod.Post, "v1/chat/completions")
        {
            Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json")
        };

        var response = await _httpClient.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, cancellationToken);

        response.EnsureSuccessStatusCode();

        await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);

        using var reader = new StreamReader(stream);

        while (!cancellationToken.IsCancellationRequested)
        {
            var line = await reader.ReadLineAsync();

            if (line == null)
            {
                yield break;
            }

            if (!line.StartsWith("data: "))
            {
                continue;
            }

            var json = line.Substring("data: ".Length);

            if (json == "[DONE]")
            {
                yield break;
            }

            using var doc = JsonDocument.Parse(json);

            var delta = doc.RootElement
                .GetProperty("choices")[0]
                .GetProperty("delta");

            if (delta.TryGetProperty("content", out var content))
            {
                var chunk = content.GetString();

                if (!string.IsNullOrEmpty(chunk))
                {
                    yield return chunk;
                }
            }
        }
    }
}

