using Epic.Api.Models;
using Epic.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace Epic.Api.Controllers;

[ApiController]
[Route("api/users/me/apps")]
public sealed class UserAppsController : ControllerBase
{
    private readonly IAppService _appService;

    public UserAppsController(IAppService appService)
    {
        _appService = appService;
    }

    /// <summary>
    /// Get apps tracked by the current user.
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(List<ManagedApp>), 200)]
    public async Task<IActionResult> GetMyApps(CancellationToken ct)
    {
        var apps = await _appService.GetUserAppsAsync(ct);
        return Ok(apps);
    }

    /// <summary>
    /// Add an existing EPIC app to the current user's tracked list.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(ManagedApp), 201)]
    [ProducesResponseType(400)]
    public async Task<IActionResult> AddToMyApps([FromBody] AddAppRequest request, CancellationToken ct)
    {
        var app = await _appService.AddToMyAppsAsync(request.Name, ct);
        return Created($"api/users/me/apps", app);
    }

    /// <summary>
    /// Remove an app from the current user's tracked list.
    /// </summary>
    [HttpDelete("{name}")]
    [ProducesResponseType(204)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> RemoveFromMyApps(string name, CancellationToken ct)
    {
        try
        {
            await _appService.RemoveFromMyAppsAsync(name, ct);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }
}
