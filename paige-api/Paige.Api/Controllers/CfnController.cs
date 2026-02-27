using System.Text;
using System.Text.Json;
using System.Threading.Channels;

using Microsoft.AspNetCore.Mvc;

using Paige.Api.Engine.CfnConverter.Cfn;
using Paige.Api.Engine.CfnConverter.Terraform;
using Paige.Api.Engine.Common;
using Paige.Api.Engine.Job;

namespace Paige.Api.Controllers;

[ApiController]
[Route("api/cfn")]
public sealed class CfnController : ControllerBase
{
    private readonly CfnExecutionService _cfnExecutionService;
    private readonly TerraformProjectBuilder _terraformProjectBuilder;

    public CfnController(
        CfnExecutionService cfnExecutionService,
        TerraformProjectBuilder terraformProjectBuilder)
    {
        _cfnExecutionService = cfnExecutionService;
        _terraformProjectBuilder = terraformProjectBuilder;
    }

    [HttpPost("create-project")]
    public ActionResult<JobResponse> CreateProject([FromBody] CfnGenerationResponse request)
    {
        if (request.CfnResults == null || request.CfnResults.Count == 0)
        {
            return BadRequest("No CloudFormation templates provided.");
        }

        var terraformProject = _terraformProjectBuilder.Build(request.CfnResults);

        return Ok(terraformProject);
    }

    [HttpPost("generate")]
    public ActionResult<JobResponse> StartGeneration([FromBody] CfnGenerationRequest request)
    {
        if (request.Cfns == null || request.Cfns.Count == 0)
        {
            return BadRequest("No CloudFormation templates provided.");
        }

        var jobId = JobStore<IReadOnlyList<CfnInput>>.CreateJob(request.Cfns);

        return Ok(new JobResponse { JobId = jobId });
    }

    [HttpGet("generate-stream/{jobId}")]
    public async Task StreamGeneration(string jobId, CancellationToken requestToken)
    {
        if (!JobStore<IReadOnlyList<CfnInput>>.TryGetJob(jobId, out var job))
        {
            Response.StatusCode = StatusCodes.Status404NotFound;

            return;
        }

        using var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(requestToken, job.Cancellation.Token);

        var cancellationToken = linkedCts.Token;

        Response.Headers["Content-Type"] = "text/event-stream";
        Response.Headers["Cache-Control"] = "no-cache";
        Response.Headers["X-Accel-Buffering"] = "no";
        Response.Headers["Connection"] = "keep-alive";
        Response.Headers["Content-Encoding"] = "none";

        var channel = Channel.CreateUnbounded<ModuleStreamMessage>();
        var writerTask = WriteStreamAsync(channel.Reader, Response.Body, cancellationToken);
        var executionTasks = job.Request.Select(cfn => ProcessModuleAsync(cfn, channel.Writer, cancellationToken));

        try
        {
            await Task.WhenAll(executionTasks);
        }
        catch (OperationCanceledException)
        {
            // expected – user canceled or connection dropped
        }
        finally
        {
            channel.Writer.TryComplete();

            await writerTask;

            JobStore<IReadOnlyList<CfnInput>>.CompleteJob(jobId);
        }
    }

    [HttpPost("cancel/{jobId}")]
    public IActionResult Cancel(string jobId)
    {
        JobStore<IReadOnlyList<CfnInput>>.CancelJob(jobId);

        return NoContent();
    }

    private async Task ProcessModuleAsync(CfnInput input, ChannelWriter<ModuleStreamMessage> writer, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        try
        {
            Console.WriteLine($"START {input.Module}");

            var result = await _cfnExecutionService.GenerateTerraformAsync(input.RawCfn, cancellationToken);
            var output = result.Output.Replace("```json" , "").Replace("```", "");

            using var doc = JsonDocument.Parse(output);

            await writer.WriteAsync(
                new ModuleStreamMessage
                {
                    Module = input.Module,
                    Files = doc.RootElement.GetProperty("files").Clone()
                },
                cancellationToken);

            Console.WriteLine($"END {input.Module}");
        }
        catch (OperationCanceledException)
        {
            Console.WriteLine($"CANCELLED {input.Module}");

            throw;
        }
    }

    private static async Task WriteStreamAsync(ChannelReader<ModuleStreamMessage> reader, Stream responseBody, CancellationToken cancellationToken)
    {
        var encoding = Encoding.UTF8;

        await foreach (var message in reader.ReadAllAsync(cancellationToken))
        {
            var payload = JsonSerializer.Serialize(new
            {
                module = message.Module,
                files = message.Files
            });

            var data = $"data: {payload}\n\n";
            var bytes = encoding.GetBytes(data);

            await responseBody.WriteAsync(bytes, cancellationToken);
            await responseBody.FlushAsync(cancellationToken);
        }

        var complete = "event: complete\n" + "data: {}\n\n";

        await responseBody.WriteAsync(encoding.GetBytes(complete), cancellationToken);
        await responseBody.FlushAsync(cancellationToken);
        await Task.Delay(100, cancellationToken);
    }
}

