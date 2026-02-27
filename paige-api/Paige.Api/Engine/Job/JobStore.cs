using System.Collections.Concurrent;

namespace Paige.Api.Engine.Job;

public static class JobStore<T>
{
    private static readonly ConcurrentDictionary<string, JobRequest<T>> _jobs = new();

    public static string CreateJob(T request)
    {
        var jobId = Guid.NewGuid().ToString("N");

        _jobs[jobId] = new JobRequest<T>
        {
            Request = request,
            Cancellation = new CancellationTokenSource()
        };

        return jobId;
    }

    public static bool TryGetJob(string jobId, out JobRequest<T> job)
    {
        return _jobs.TryGetValue(jobId, out job!);
    }

    public static void CancelJob(string jobId)
    {
        if (_jobs.TryRemove(jobId, out var job))
        {
            job.Cancellation.Cancel();
            job.Cancellation.Dispose();
        }
    }

    public static void CompleteJob(string jobId)
    {
        if (_jobs.TryRemove(jobId, out var job))
        {
            job.Cancellation.Dispose();
        }
    }
}