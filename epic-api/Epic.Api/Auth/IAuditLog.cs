namespace Epic.Api.Auth;

/// <summary>
/// Emits security-relevant audit records for state-changing operations
/// (onboarding, run triggers/cancels, app-list changes, data purges).
///
/// Each record carries the six audit-record fields required by the PG&amp;E T&amp;S
/// controls (NIST AU-02 / AC-12): what (eventType), when (UTC timestamp),
/// where (resource), source (client IP), outcome, and the identity of the
/// individual associated with the event. This is distinct from operational
/// logging (external-API failure warnings) — it is the audit-of-record for
/// who did what in EPIC.
/// </summary>
public interface IAuditLog
{
    /// <summary>Record a successful security-relevant action.</summary>
    void Record(string eventType, string resource, string outcome = "success", string? detail = null);
}
