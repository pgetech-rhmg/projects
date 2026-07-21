namespace Epic.Api.Data.Entities;

/// <summary>
/// Canonical string values for a pipeline run's per-stage status, persisted on
/// <see cref="PipelineRunEntity"/>. Centralized so the literals aren't repeated
/// across the entity defaults and the ADO-refresh code.
/// </summary>
public static class StageStatuses
{
    public const string Skipped = "Skipped";
}
