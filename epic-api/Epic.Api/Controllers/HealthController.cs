using Epic.Api.Data;
using Microsoft.AspNetCore.Mvc;

namespace Epic.Api.Controllers;

[ApiController]
[Route("api/health")]
public sealed class HealthController(EpicDbContext db) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(200)]
    [ProducesResponseType(503)]
    public async Task<IActionResult> Get()
    {
        var dbHealthy = false;
        try
        {
            dbHealthy = await db.Database.CanConnectAsync();
        }
        catch { /* DB unreachable */ }

        var status = dbHealthy ? "healthy" : "degraded";
        var statusCode = dbHealthy ? 200 : 503;

        return StatusCode(statusCode, new
        {
            status,
            service = "epic-api",
            timestampUtc = DateTime.UtcNow,
            checks = new
            {
                database = dbHealthy ? "ok" : "unreachable"
            }
        });
    }
}
