using System.Net;

namespace Epic.Api.UnitTests.TestHelpers;

/// <summary>
/// A test double for <see cref="HttpMessageHandler"/> that lets a test script the
/// response(s) an <see cref="HttpClient"/> receives without any network I/O. Used
/// to exercise the ADO and GitHub service HTTP glue.
///
/// Two modes:
///  - a single fixed response (the simple constructor), or
///  - a queue of responses matched by request predicate + FIFO order via
///    <see cref="Enqueue"/>, for endpoints that make several sequential calls.
///
/// Every received request is captured in <see cref="Requests"/> for assertions.
/// </summary>
public sealed class FakeHttpMessageHandler : HttpMessageHandler
{
    private readonly Func<HttpRequestMessage, HttpResponseMessage> _responder;

    public List<HttpRequestMessage> Requests { get; } = [];

    public FakeHttpMessageHandler(Func<HttpRequestMessage, HttpResponseMessage> responder)
    {
        _responder = responder;
    }

    /// <summary>Always returns a single response with the given status + body.</summary>
    public static FakeHttpMessageHandler Fixed(HttpStatusCode status, string body = "") =>
        new(_ => Build(status, body));

    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        Requests.Add(request);
        return Task.FromResult(_responder(request));
    }

    /// <summary>
    /// Builds an <see cref="HttpResponseMessage"/> with an optional
    /// x-ms-continuationtoken header (ADO pagination).
    /// </summary>
    public static HttpResponseMessage Build(HttpStatusCode status, string body, string? continuationToken = null)
    {
        var response = new HttpResponseMessage(status)
        {
            Content = new StringContent(body, System.Text.Encoding.UTF8, "application/json")
        };
        if (continuationToken is not null)
            response.Headers.Add("x-ms-continuationtoken", continuationToken);
        return response;
    }
}

/// <summary>
/// A handler that serves a scripted sequence of responses, each guarded by a
/// predicate on the request. On each call it returns the first still-unused
/// response whose predicate matches; if none match it returns 404. This models
/// endpoints that fan out to several different ADO/GitHub URLs in one operation.
/// </summary>
public sealed class RoutingHttpMessageHandler : HttpMessageHandler
{
    private readonly List<(Func<HttpRequestMessage, bool> Match, Func<HttpRequestMessage, HttpResponseMessage> Respond)> _routes = [];

    public List<HttpRequestMessage> Requests { get; } = [];

    /// <summary>Route requests whose URI contains <paramref name="fragment"/> to a fixed JSON body.</summary>
    public RoutingHttpMessageHandler When(string fragment, HttpStatusCode status, string body, string? continuationToken = null)
    {
        _routes.Add((r => r.RequestUri!.ToString().Contains(fragment, StringComparison.OrdinalIgnoreCase),
            _ => FakeHttpMessageHandler.Build(status, body, continuationToken)));
        return this;
    }

    /// <summary>Route via a custom predicate + responder for full control.</summary>
    public RoutingHttpMessageHandler When(Func<HttpRequestMessage, bool> match, Func<HttpRequestMessage, HttpResponseMessage> respond)
    {
        _routes.Add((match, respond));
        return this;
    }

    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        Requests.Add(request);
        foreach (var (match, respond) in _routes)
        {
            if (match(request))
                return Task.FromResult(respond(request));
        }
        return Task.FromResult(FakeHttpMessageHandler.Build(HttpStatusCode.NotFound, "{}"));
    }
}
