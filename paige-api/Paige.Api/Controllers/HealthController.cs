using Microsoft.AspNetCore.Mvc;

namespace Paige.Api.Controllers;

public sealed class HealthResponse
{
    public string Status { get; init; } = string.Empty;
    public string Service { get; init; } = string.Empty;
    public DateTime TimestampUtc { get; init; }
}

[ApiController]
[Route("api/health")]
public sealed class HealthController : ControllerBase
{
    [HttpGet]
    [ProducesResponseType<HealthResponse>(StatusCodes.Status200OK)]
    public IActionResult Get()
    {
        return Ok(new HealthResponse
        {
            Status = "Healthy",
            Service = "PAIGE API",
            TimestampUtc = DateTime.UtcNow
        });
    }
}
