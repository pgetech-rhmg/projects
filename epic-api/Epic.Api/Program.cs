using System.Text.Json;

using Amazon;
using Amazon.Extensions.NETCore.Setup;
using Amazon.SecretsManager;
using Amazon.SecretsManager.Model;

using Epic.Api.Data;
using Epic.Api.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------
builder.Configuration
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true)
    .AddEnvironmentVariables();

// ---------------------------------------------------------------------------
// AWS Secrets Manager (non-development only)
// ---------------------------------------------------------------------------
if (!builder.Environment.IsDevelopment())
{
    var secretName =
        builder.Configuration["AWS_SECRETS_NAME"]
        ?? throw new InvalidOperationException("AWS_SECRETS_NAME not configured.");

    var regionName =
        builder.Configuration["AWS_REGION"]
        ?? Environment.GetEnvironmentVariable("AWS_REGION")
        ?? throw new InvalidOperationException("AWS_REGION not configured.");

    var awsOptions = new AWSOptions
    {
        Region = RegionEndpoint.GetBySystemName(regionName)
    };

    using var client = awsOptions.CreateServiceClient<IAmazonSecretsManager>();

    var response = await client.GetSecretValueAsync(new GetSecretValueRequest
    {
        SecretId = secretName
    });

    if (string.IsNullOrWhiteSpace(response.SecretString))
        throw new InvalidOperationException("SecretString is empty.");

    var secrets = JsonSerializer.Deserialize<Dictionary<string, string?>>(
        response.SecretString,
        new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
    ) ?? throw new InvalidOperationException("Failed to deserialize secrets.");

    // Convert double-underscore keys to colon notation for .NET configuration
    // (e.g., ConnectionStrings__EpicDb → ConnectionStrings:EpicDb)
    var normalizedSecrets = secrets.ToDictionary(
        kvp => kvp.Key.Replace("__", ":"),
        kvp => kvp.Value
    );

    builder.Configuration.AddInMemoryCollection(normalizedSecrets);
}

// ---------------------------------------------------------------------------
// CORS
// ---------------------------------------------------------------------------
builder.Services.AddCors(options =>
{
    options.AddPolicy("ApiCorsPolicy", policy =>
    {
        policy.WithOrigins(
                "https://epic-dev.nonprod.pge.com",
                "http://localhost:4200",
                "https://localhost:4200")
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------
builder.Services.AddDbContext<EpicDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("EpicDb")));

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(
            new System.Text.Json.Serialization.JsonStringEnumConverter());
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new()
    {
        Title = "EPIC API",
        Description = "Enterprise Pipeline for Integration and Continuous Delivery"
    });
});

builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<Epic.Api.Auth.ICurrentUser, Epic.Api.Auth.HeaderCurrentUser>();
builder.Services.AddHttpClient<IGitHubService, GitHubService>();
builder.Services.AddHttpClient<IAdoService, AdoService>();
builder.Services.AddScoped<IAppService, AppService>();

// ---------------------------------------------------------------------------
// Build & Configure
// ---------------------------------------------------------------------------
var app = builder.Build();

// Apply pending EF Core migrations on startup (idempotent)
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<EpicDbContext>();
    db.Database.Migrate();
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("ApiCorsPolicy");
app.UseAuthorization();
app.MapControllers();

await app.RunAsync();
