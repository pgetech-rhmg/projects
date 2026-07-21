using System.Text.Json;

namespace Epic.Api.UnitTests.TestHelpers;

/// <summary>
/// Builders for the ADO REST JSON shapes AdoService parses. Kept as string
/// builders (rather than typed models) so tests exercise the same
/// JsonDocument parsing path production uses.
/// </summary>
public static class AdoJson
{
    /// <summary>A /build/builds list response wrapping the given build objects.</summary>
    public static string BuildList(params string[] builds) =>
        $"{{\"count\":{builds.Length},\"value\":[{string.Join(",", builds)}]}}";

    /// <summary>
    /// A single build object. All fields optional so a test can include only the
    /// properties the branch under test cares about.
    /// </summary>
    public static string Build(
        int id,
        string status = "completed",
        string? result = "succeeded",
        string? branch = null,
        string? environment = null,
        string? triggeredBy = null,
        string? parametersJson = null,
        string? sourceBranch = null,
        DateTime? startTime = null,
        DateTime? queueTime = null,
        DateTime? finishTime = null,
        IEnumerable<string>? tags = null,
        int? engineIdTag = null,
        bool includeTemplateParameters = true)
    {
        var props = new List<string> { $"\"id\":{id}" };
        if (status is not null) props.Add($"\"status\":{Str(status)}");
        if (result is not null) props.Add($"\"result\":{Str(result)}");

        if (includeTemplateParameters && (branch is not null || environment is not null || triggeredBy is not null))
        {
            var tp = new List<string>();
            if (branch is not null) tp.Add($"\"branch\":{Str(branch)}");
            if (environment is not null) tp.Add($"\"environment\":{Str(environment)}");
            if (triggeredBy is not null) tp.Add($"\"triggeredBy\":{Str(triggeredBy)}");
            props.Add($"\"templateParameters\":{{{string.Join(",", tp)}}}");
        }

        if (parametersJson is not null)
            props.Add($"\"parameters\":{Str(parametersJson)}");
        if (sourceBranch is not null)
            props.Add($"\"sourceBranch\":{Str(sourceBranch)}");
        if (startTime.HasValue)
            props.Add($"\"startTime\":{Str(Iso(startTime.Value))}");
        if (queueTime.HasValue)
            props.Add($"\"queueTime\":{Str(Iso(queueTime.Value))}");
        if (finishTime.HasValue)
            props.Add($"\"finishTime\":{Str(Iso(finishTime.Value))}");

        var allTags = new List<string>();
        if (tags is not null) allTags.AddRange(tags);
        if (engineIdTag.HasValue) allTags.Add($"epicEngineId.{engineIdTag.Value}");
        if (allTags.Count > 0)
            props.Add($"\"tags\":[{string.Join(",", allTags.Select(Str))}]");

        return $"{{{string.Join(",", props)}}}";
    }

    /// <summary>A timeline response with the given records.</summary>
    public static string Timeline(params string[] records) =>
        $"{{\"records\":[{string.Join(",", records)}]}}";

    public static string StageRecord(string id, string name, string state = "completed", string? result = "succeeded", string? parentId = null) =>
        Record(id, "Stage", name, state, result, parentId);

    public static string Record(string id, string type, string? name, string? state, string? result, string? parentId = null, int? order = null, int? logId = null, DateTime? start = null, DateTime? finish = null)
    {
        var props = new List<string> { $"\"id\":{Str(id)}", $"\"type\":{Str(type)}" };
        if (name is not null) props.Add($"\"name\":{Str(name)}");
        if (state is not null) props.Add($"\"state\":{Str(state)}");
        if (result is not null) props.Add($"\"result\":{Str(result)}");
        if (parentId is not null) props.Add($"\"parentId\":{Str(parentId)}");
        if (order.HasValue) props.Add($"\"order\":{order.Value}");
        if (logId.HasValue) props.Add($"\"log\":{{\"id\":{logId.Value}}}");
        if (start.HasValue) props.Add($"\"startTime\":{Str(Iso(start.Value))}");
        if (finish.HasValue) props.Add($"\"finishTime\":{Str(Iso(finish.Value))}");
        return $"{{{string.Join(",", props)}}}";
    }

    public static string Iso(DateTime dt) => dt.ToUniversalTime().ToString("o");

    private static string Str(string s) => JsonSerializer.Serialize(s);
}
