using System.Text;
using System.Text.Json;
using Epic.Api.Services;
using Epic.Api.Startup;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace Epic.Api.UnitTests.Startup;

public sealed class ExceptionHandlingMiddlewareTests
{
    private static async Task<(int Status, string Body)> Run(Exception? toThrow)
    {
        var ctx = new DefaultHttpContext();
        ctx.Response.Body = new MemoryStream();

        RequestDelegate next = _ => toThrow is null ? Task.CompletedTask : throw toThrow;
        var mw = new ExceptionHandlingMiddleware(next, NullLogger<ExceptionHandlingMiddleware>.Instance);

        await mw.InvokeAsync(ctx);

        ctx.Response.Body.Seek(0, SeekOrigin.Begin);
        var body = await new StreamReader(ctx.Response.Body, Encoding.UTF8).ReadToEndAsync();
        return (ctx.Response.StatusCode, body);
    }

    [Fact]
    public async Task PassesThroughWhenNoException()
    {
        var (status, body) = await Run(null);
        Assert.Equal(200, status);      // untouched
        Assert.Empty(body);
    }

    [Theory]
    [InlineData(typeof(UnauthorizedAccessException), 401)]
    [InlineData(typeof(KeyNotFoundException), 404)]
    [InlineData(typeof(InvalidOperationException), 500)]   // unmapped → real 500 (not phantom CORS)
    public async Task MapsKnownExceptionsToStatus(Type exType, int expected)
    {
        var ex = (Exception)Activator.CreateInstance(exType, "boom")!;
        var (status, body) = await Run(ex);

        Assert.Equal(expected, status);
        using var doc = JsonDocument.Parse(body);
        Assert.Equal(expected, doc.RootElement.GetProperty("status").GetInt32());
        Assert.False(string.IsNullOrWhiteSpace(doc.RootElement.GetProperty("error").GetString()));
    }

    [Fact]
    public async Task UnknownGitHubSource_MapsTo400()
    {
        var (status, body) = await Run(new UnknownGitHubSourceException("bogus"));
        Assert.Equal(400, status);
        using var doc = JsonDocument.Parse(body);
        Assert.Contains("bogus", doc.RootElement.GetProperty("error").GetString());
    }

    [Fact]
    public async Task AdoUpstream_MapsTo502()
    {
        var (status, body) = await Run(new AdoUpstreamException(403, "forbidden"));
        Assert.Equal(502, status);
        using var doc = JsonDocument.Parse(body);
        Assert.Equal(502, doc.RootElement.GetProperty("status").GetInt32());
    }
}
