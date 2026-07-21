namespace Epic.Api.Auth;

/// <summary>
/// Default <see cref="IAuditLog"/> — emits one structured log record per event
/// with all six required audit fields. Records are tagged with the
/// <c>Audit</c> category and event-type/actor/resource/outcome as structured
/// properties so a downstream log pipeline (CloudWatch) can filter and retain
/// them per the records-retention policy (AU-10/AU-11 are the retention side;
/// this covers generation + content, AU-02/AC-12/AU-06/AU-08).
/// </summary>
public sealed class AuditLog(ILogger<AuditLog> logger, ICurrentUser currentUser, IHttpContextAccessor httpContextAccessor)
    : IAuditLog
{
    public void Record(string eventType, string resource, string outcome = "success", string? detail = null)
    {
        // Identity (f) — resolve defensively; auditing must never throw and break
        // the operation it is recording.
        string actor;
        try { actor = currentUser.UserId; }
        catch { actor = "unknown"; }

        // Source (d) — client IP of the request that caused the event.
        var sourceIp =
            httpContextAccessor.HttpContext?.Connection.RemoteIpAddress?.ToString()
            ?? "unknown";

        // what (a), when (b, UTC), where (c), source (d), outcome (e), identity (f).
        // The timestamp is passed as a raw DateTime with an :O format specifier so
        // the string is only rendered if the record is actually emitted (CA1873).
        logger.LogInformation(
            "AUDIT event={AuditEventType} actor={AuditActor} resource={AuditResource} outcome={AuditOutcome} sourceIp={AuditSourceIp} timestampUtc={AuditTimestampUtc:O} detail={AuditDetail}",
            eventType,
            actor,
            resource,
            outcome,
            sourceIp,
            DateTime.UtcNow,
            detail ?? "");
    }
}
