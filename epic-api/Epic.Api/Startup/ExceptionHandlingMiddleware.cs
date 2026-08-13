using System.Text.Json;
using Epic.Api.Services;

namespace Epic.Api.Startup;

/// <summary>
/// Catches any exception that escapes a controller action and turns it into a
/// clean JSON error response with the right status code.
///
/// Why this exists: without it, an unhandled exception becomes a bare 500 whose
/// response is reset by the framework — which drops the CORS headers that
/// <c>UseCors</c> added via an <c>OnStarting</c> callback. The browser then
/// reports the real 500 as a misleading "No 'Access-Control-Allow-Origin'
/// header" CORS error, hiding the actual failure. (This is exactly how the
/// duplicate-onboard 500 first showed up.)
///
/// Placement + behavior are load-bearing for keeping CORS intact:
///   * Registered AFTER <c>UseCors</c>, so on the way in the CORS middleware has
///     already queued its <c>OnStarting</c> header callback before this
///     middleware's try/catch wraps the endpoint.
///   * On catch we set the status code and write the body WITHOUT clearing the
///     response (no <c>Response.Clear()</c>), so that queued CORS callback still
///     fires when the response flushes — the error response carries ACAO.
/// If the response has already started we can't intervene, so we rethrow.
/// </summary>
public sealed class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex) when (!context.Response.HasStarted)
        {
            var (status, message) = Map(ex);

            if (status >= 500)
                logger.LogError(ex, "Unhandled exception → {Status} on {Method} {Path}", status, context.Request.Method, context.Request.Path);
            else
                logger.LogInformation(ex, "Handled exception → {Status} on {Method} {Path}", status, context.Request.Method, context.Request.Path);

            context.Response.StatusCode = status;
            context.Response.ContentType = "application/json";
            await context.Response.WriteAsync(JsonSerializer.Serialize(new { error = message, status }));
        }
    }

    /// <summary>
    /// Maps an exception to (status, client-safe message). Conservative on
    /// purpose: only exception types with an unambiguous client meaning get a
    /// 4xx. Everything else is a 500 — but a 500 that is now a real,
    /// CORS-bearing JSON response the frontend can read, not a phantom CORS
    /// error. Controllers that already translate a type (e.g. OnboardApp
    /// mapping InvalidOperationException → 400) run first, so this only handles
    /// what they let through.
    /// </summary>
    private static (int Status, string Message) Map(Exception ex) => ex switch
    {
        UnauthorizedAccessException => (401, "Not authorized."),
        UnknownGitHubSourceException e => (400, e.Message),
        KeyNotFoundException e => (404, e.Message),
        AdoUpstreamException => (502, "The pipeline service (Azure DevOps) returned an error."),
        _ => (500, "An unexpected error occurred."),
    };
}
