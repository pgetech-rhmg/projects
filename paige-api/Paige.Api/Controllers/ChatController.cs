using System.Text;

using Microsoft.AspNetCore.Mvc;

using Paige.Api.Engine.Chat;
using Paige.Api.Engine.Job;

namespace Paige.Api.Controllers;

[ApiController]
[Route("api/chat")]
public sealed class ChatController : ControllerBase
{
    private readonly ChatExecutionService _chatExecutionService;

    public ChatController(ChatExecutionService chatExecutionService)
    {
        _chatExecutionService = chatExecutionService;
    }

    // ------------------------------------------------------------
    // NON-STREAMING (simple request/response)
    // ------------------------------------------------------------
    [HttpPost("send")]
    public async Task<ActionResult<JobResponse>> SendMessage([FromBody] ChatRequest request, CancellationToken cancellationToken)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.Prompt))
        {
            return BadRequest("No message provided.");
        }

        var response = await _chatExecutionService.SendMessageAsync(request, cancellationToken);

        return Ok(response);
    }

    // ------------------------------------------------------------
    // STREAMING – START (POST)
    // ------------------------------------------------------------
    [HttpPost("start")]
    public ActionResult<JobResponse> StartChat([FromBody] ChatRequest request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.Prompt))
        {
            return BadRequest("No message provided.");
        }

        var jobId = JobStore<ChatRequest>.CreateJob(request);

        return Ok(new JobResponse { JobId = jobId });
    }

    // ------------------------------------------------------------
    // STREAMING – SSE OUTPUT (GET)
    // ------------------------------------------------------------
    [HttpGet("stream/{jobId}")]
    public async Task StreamChat(string jobId, CancellationToken requestToken)
    {
        if (!JobStore<ChatRequest>.TryGetJob(jobId, out var job))
        {
            Response.StatusCode = StatusCodes.Status404NotFound;

            return;
        }

        using var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(requestToken, job.Cancellation.Token);

        var cancellationToken = linkedCts.Token;

        Response.Headers["Content-Type"] = "text/event-stream";
        Response.Headers["Cache-Control"] = "no-cache, no-transform";
        Response.Headers["X-Accel-Buffering"] = "no";
        Response.Headers["Connection"] = "keep-alive";

        try
        {
            await foreach (var chunk in _chatExecutionService.SendMessageStreamAsync(job.Request, cancellationToken))
            {
                var data = ToSseData(chunk);

                await Response.Body.WriteAsync(data, cancellationToken);
                await Response.Body.FlushAsync(cancellationToken);
            }
        }
        catch (OperationCanceledException)
        {
            // expected – user canceled or connection dropped
        }
        finally
        {
            var complete = "event: complete\n" + "data: {}\n\n";

            await Response.Body.WriteAsync(Encoding.UTF8.GetBytes(complete), cancellationToken);

            await Response.Body.FlushAsync(cancellationToken);

            JobStore<ChatRequest>.CompleteJob(jobId);
        }
    }

    // ------------------------------------------------------------
    // STREAMING – CANCEL
    // ------------------------------------------------------------
    [HttpPost("cancel/{jobId}")]
    public IActionResult CancelChat(string jobId)
    {
        JobStore<ChatRequest>.CancelJob(jobId);

        return NoContent();
    }

    // ------------------------------------------------------------
    // SSE framing helper
    // ------------------------------------------------------------
    private static byte[] ToSseData(string text)
    {
        var sb = new StringBuilder();

        text = text.Replace("\r\n", "\n");

        var lines = text.Split('\n', StringSplitOptions.None);

        foreach (var line in lines)
        {
            sb.Append("data: ");
            sb.Append(line);
            sb.Append('\n');
        }

        // End SSE event
        sb.Append('\n');

        return Encoding.UTF8.GetBytes(sb.ToString());
    }
}

