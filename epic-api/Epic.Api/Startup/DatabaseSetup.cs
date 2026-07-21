using System.Text.Json;

using Amazon;
using Amazon.Extensions.NETCore.Setup;
using Amazon.SecretsManager;
using Amazon.SecretsManager.Model;

using Epic.Api.Data;

using Microsoft.EntityFrameworkCore;

using Npgsql;

namespace Epic.Api.Startup;

/// <summary>
/// Registers the EF Core <see cref="EpicDbContext"/>.
///
/// In deployed environments the Aurora master password is owned by RDS and
/// rotated automatically (every 7 days). The API therefore must NOT bake the
/// password into a connection string once at startup — if it did, every DB call
/// would authenticate with a stale password after each rotation, 500-ing until a
/// manual restart re-read the secret. Instead we build an <see cref="NpgsqlDataSource"/>
/// with a *periodic password provider*: Npgsql re-fetches the current password
/// from Secrets Manager on an interval, so a rotation self-heals within that
/// window with no restart. In Development we fall back to the static connection
/// string from configuration.
/// </summary>
public static class DatabaseSetup
{
    // How often to proactively refresh the DB password from Secrets Manager.
    // Sets the worst-case self-heal window after a rotation; Secrets Manager
    // GetSecretValue is cheap, so a short interval costs almost nothing.
    private static readonly TimeSpan PasswordRefreshInterval = TimeSpan.FromMinutes(5);

    // Faster retry cadence when a refresh fails (e.g. transient Secrets Manager blip).
    private static readonly TimeSpan PasswordRefreshFailureInterval = TimeSpan.FromSeconds(10);

    private const int PostgresPort = 5432;
    private const string DefaultDatabase = "epicdb";
    private const string DefaultUsername = "epic";

    private static readonly JsonSerializerOptions SecretJsonOptions =
        new() { PropertyNameCaseInsensitive = true };

    /// <summary>
    /// Registers <see cref="EpicDbContext"/>. Uses a rotation-aware data source
    /// when an RDS-managed secret is configured (deployed environments); otherwise
    /// the static connection string from configuration (Development / local).
    /// </summary>
    public static void AddEpicDatabase(WebApplicationBuilder builder)
    {
        var rdsSecretArn = builder.Configuration["AWS_RDS_SECRET_ARN"];
        var dbHost = builder.Configuration["AWS_RDS_ENDPOINT"];

        var useRotatingSecret = !builder.Environment.IsDevelopment()
            && !string.IsNullOrEmpty(rdsSecretArn)
            && !string.IsNullOrEmpty(dbHost);

        if (useRotatingSecret)
        {
            var regionName = builder.Configuration["AWS_REGION"]
                ?? Environment.GetEnvironmentVariable("AWS_REGION")
                ?? throw new InvalidOperationException("AWS_REGION not configured.");
            var region = RegionEndpoint.GetBySystemName(regionName);
            var database = builder.Configuration["AWS_RDS_DATABASE"] ?? DefaultDatabase;

            var dataSource = BuildRotatingDataSource(rdsSecretArn!, dbHost!, region, database);
            builder.Services.AddSingleton(dataSource);
            builder.Services.AddDbContext<EpicDbContext>(options => options.UseNpgsql(dataSource));
            return;
        }

        builder.Services.AddDbContext<EpicDbContext>(options =>
            options.UseNpgsql(builder.Configuration.GetConnectionString("EpicDb")));
    }

    // Builds a data source whose password is fetched from Secrets Manager on a
    // timer. The username is read once (only the password rotates), and the base
    // connection string is intentionally password-less so the provider supplies it.
    private static NpgsqlDataSource BuildRotatingDataSource(
        string rdsSecretArn, string dbHost, RegionEndpoint region, string database)
    {
        var awsOptions = new AWSOptions { Region = region };
        // Held for the lifetime of the data source (app lifetime) — the periodic
        // provider closes over it, so it is deliberately not disposed here.
        var client = awsOptions.CreateServiceClient<IAmazonSecretsManager>();

        var (username, _) = FetchRdsCredentialsAsync(client, rdsSecretArn).GetAwaiter().GetResult();

        var connectionString = new NpgsqlConnectionStringBuilder
        {
            Host = dbHost,
            Port = PostgresPort,
            Database = database,
            Username = username,
        }.ConnectionString;

        var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);
        dataSourceBuilder.UsePeriodicPasswordProvider(
            async (_, cancellationToken) =>
            {
                var (_, password) = await FetchRdsCredentialsAsync(client, rdsSecretArn, cancellationToken);
                return password;
            },
            PasswordRefreshInterval,
            PasswordRefreshFailureInterval);

        return dataSourceBuilder.Build();
    }

    private static async Task<(string Username, string Password)> FetchRdsCredentialsAsync(
        IAmazonSecretsManager client, string rdsSecretArn, CancellationToken cancellationToken = default)
    {
        var response = await client.GetSecretValueAsync(
            new GetSecretValueRequest { SecretId = rdsSecretArn }, cancellationToken);

        var secret = JsonSerializer.Deserialize<Dictionary<string, string?>>(
                response.SecretString!, SecretJsonOptions)
            ?? throw new InvalidOperationException($"RDS secret '{rdsSecretArn}' is not a valid JSON object.");

        var username = secret.GetValueOrDefault("username") ?? DefaultUsername;
        var password = secret.GetValueOrDefault("password")
            ?? throw new InvalidOperationException("RDS secret missing password.");

        return (username, password);
    }
}
