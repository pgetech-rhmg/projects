using System.Text.Json;

namespace Paige.Api.Engine.Common;

public sealed class ModuleStreamMessage
{
    public required string Module { get; init; }
    public required JsonElement Files { get; init; }
}
