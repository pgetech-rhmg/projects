using System.Text.Json;

using Amazon;
using Amazon.Extensions.NETCore.Setup;
using Amazon.SecretsManager;
using Amazon.SecretsManager.Model;

namespace Epic.Api.Startup;

/// <summary>
/// Loads application + RDS secrets from AWS Secrets Manager into configuration at
/// startup (non-development only). Extracted from Program.cs so the bootstrap
/// stays flat and this AWS-specific wiring is isolated.
/// </summary>
public static class SecretsLoader
{
    private static readonly JsonSerializerOptions SecretJsonOptions =
        new() { PropertyNameCaseInsensitive = true };

    /// <summary>
    /// Pulls the app secret (and, if configured, the RDS secret) into
    /// <paramref name="builder"/>'s configuration. No-op in Development.
    /// </summary>
    public static async Task LoadAsync(WebApplicationBuilder builder)
    {
        if (builder.Environment.IsDevelopment())
            return;

        var secretName = builder.Configuration["AWS_SECRETS_NAME"]
            ?? throw new InvalidOperationException("AWS_SECRETS_NAME not configured.");
        var regionName = builder.Configuration["AWS_REGION"]
            ?? Environment.GetEnvironmentVariable("AWS_REGION")
            ?? throw new InvalidOperationException("AWS_REGION not configured.");

        var awsOptions = new AWSOptions { Region = RegionEndpoint.GetBySystemName(regionName) };
        using var client = awsOptions.CreateServiceClient<IAmazonSecretsManager>();

        var appSecrets = await LoadAppSecretsAsync(client, secretName);
        builder.Configuration.AddInMemoryCollection(appSecrets);

        // The RDS database connection is NOT assembled here. Because the Aurora
        // master password rotates (every 7 days), baking it into a static
        // connection string at startup would break every DB call after each
        // rotation until a manual restart. DatabaseSetup instead builds a
        // rotation-aware NpgsqlDataSource that re-fetches the password on a timer.
    }

    // Reads the main app secret and normalizes __ keys to : (config section) form.
    private static async Task<Dictionary<string, string?>> LoadAppSecretsAsync(IAmazonSecretsManager client, string secretName)
    {
        var response = await client.GetSecretValueAsync(new GetSecretValueRequest { SecretId = secretName });
        if (string.IsNullOrWhiteSpace(response.SecretString))
            throw new InvalidOperationException("SecretString is empty.");

        var secrets = Deserialize(response.SecretString,
            $"Secret '{secretName}' is not a valid JSON object of string-to-string entries.");

        // Convert double-underscore keys to colon notation for .NET configuration
        // (e.g., ConnectionStrings__EpicDb → ConnectionStrings:EpicDb).
        return secrets.ToDictionary(kvp => kvp.Key.Replace("__", ":"), kvp => kvp.Value);
    }

    private static Dictionary<string, string?> Deserialize(string json, string errorMessage)
    {
        try
        {
            return JsonSerializer.Deserialize<Dictionary<string, string?>>(json, SecretJsonOptions)
                ?? throw new InvalidOperationException("Failed to deserialize secret.");
        }
        catch (JsonException ex)
        {
            throw new InvalidOperationException(errorMessage, ex);
        }
    }
}
