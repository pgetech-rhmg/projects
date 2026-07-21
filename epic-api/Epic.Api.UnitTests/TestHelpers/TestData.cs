using Epic.Api.Auth;
using Epic.Api.Data;
using Epic.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;

namespace Epic.Api.UnitTests.TestHelpers;

/// <summary>Shared builders/fakes for the epic-api test suite.</summary>
public static class TestData
{
    /// <summary>A fresh in-memory EpicDbContext with a unique database name.</summary>
    public static EpicDbContext NewDb(string? name = null)
    {
        var options = new DbContextOptionsBuilder<EpicDbContext>()
            .UseInMemoryDatabase(name ?? Guid.NewGuid().ToString())
            .Options;
        return new EpicDbContext(options);
    }

    /// <summary>A real MemoryCache with a size limit (services use Size = 1 entries).</summary>
    public static IMemoryCache NewCache() =>
        new MemoryCache(new MemoryCacheOptions { SizeLimit = 50_000 });

    public static ILogger<T> Logger<T>() => NullLogger<T>.Instance;

    /// <summary>An IConfiguration backed by the given key/value pairs.</summary>
    public static IConfiguration Config(params (string Key, string? Value)[] entries) =>
        new ConfigurationBuilder()
            .AddInMemoryCollection(entries.Select(e => new KeyValuePair<string, string?>(e.Key, e.Value)))
            .Build();

    public static AppEntity NewApp(string name = "epic-web", string? repo = null, int id = 0) => new()
    {
        Id = id,
        Name = name,
        DisplayName = name,
        AppType = "angular",
        Technology = "Angular",
        Cloud = "AWS",
        Environment = "dev",
        Team = "unassigned",
        Domain = "",
        GithubRepo = repo ?? name,
        GithubBranch = "main",
        HasInfra = false,
        CreatedBy = "Morgan, Robb",
        LastUpdatedBy = "Morgan, Robb"
    };

    public static PipelineRunEntity NewRun(int id, int appId, string status = "Success", DateTime? startedAt = null) => new()
    {
        Id = id,
        AppId = appId,
        Status = status,
        TriggeredBy = "Morgan, Robb",
        Branch = "main",
        Environment = "dev",
        StartedAt = startedAt ?? new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc)
    };
}

/// <summary>Deterministic ICurrentUser for service tests.</summary>
public sealed class StubCurrentUser(string userId = "rhmg", string displayName = "Morgan, Robb") : ICurrentUser
{
    public string UserId { get; } = userId;
    public string DisplayName { get; } = displayName;
}

/// <summary>Records audit calls so tests can assert they fired.</summary>
public sealed class RecordingAuditLog : IAuditLog
{
    public List<(string EventType, string Resource, string Outcome, string? Detail)> Records { get; } = [];

    public void Record(string eventType, string resource, string outcome = "success", string? detail = null) =>
        Records.Add((eventType, resource, outcome, detail));
}
