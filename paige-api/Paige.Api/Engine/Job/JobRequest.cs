namespace Paige.Api.Engine.Job;

public sealed class JobRequest<T>
{
    public required T Request { get; init; }

    public required CancellationTokenSource Cancellation { get; init; }
}
