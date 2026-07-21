using Epic.Api.Data;
using Epic.Api.Services;
using Epic.Api.Startup;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Http.Resilience;
using Microsoft.IdentityModel.Tokens;
using Polly;

var builder = WebApplication.CreateBuilder(args);

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------
builder.Configuration
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true)
    .AddEnvironmentVariables();

// ---------------------------------------------------------------------------
// AWS Secrets Manager (non-development only) — loads app + RDS secrets into
// configuration. See Epic.Api.Startup.SecretsLoader.
// ---------------------------------------------------------------------------
await SecretsLoader.LoadAsync(builder);

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
            .WithMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
            .AllowCredentials();
    });
});

// ---------------------------------------------------------------------------
// Authentication & Authorization
//
// Validates Entra ID (MSAL) ID tokens: RS256 via the tenant JWKS (auto-fetched
// and cached), issuer = login.microsoftonline.com/{tenant}/v2.0, audience =
// the app registration's client ID (ID tokens always carry the client ID in
// `aud`). Mirrors the CMA authorizer's validation semantics.
//
// In Development, authentication is bypassed entirely: endpoints allow
// anonymous access and identity comes from DevCurrentUser, so local `dotnet
// run` works without a real token.
// ---------------------------------------------------------------------------
var authEnabled = !builder.Environment.IsDevelopment();

if (authEnabled)
{
    var tenantId = builder.Configuration["AzureAd:TenantId"]
        ?? throw new InvalidOperationException("AzureAd:TenantId not configured.");
    var clientId = builder.Configuration["AzureAd:ClientId"]
        ?? throw new InvalidOperationException("AzureAd:ClientId not configured.");
    var instance = builder.Configuration["AzureAd:Instance"] ?? "https://login.microsoftonline.com/";
    var authority = $"{instance.TrimEnd('/')}/{tenantId}/v2.0";

    builder.Services
        .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            options.Authority = authority;
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = authority,
                ValidateAudience = true,
                ValidAudience = clientId,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
            };
        });

    // Deny by default: every endpoint requires an authenticated user unless it
    // opts out with [AllowAnonymous].
    builder.Services.AddAuthorizationBuilder()
        .SetFallbackPolicy(new AuthorizationPolicyBuilder()
            .RequireAuthenticatedUser()
            .Build());
}
else
{
    builder.Services.AddAuthorization();
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------
DatabaseSetup.AddEpicDatabase(builder);

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

// In-memory cache for ADO timeline + run-count results.
// Sized to ~50k entries — a 50-byte PipelineStages * 50k ≈ 2.5 MB worst case.
builder.Services.AddMemoryCache(options => options.SizeLimit = 50_000);

builder.Services.AddHttpContextAccessor();
if (authEnabled)
    builder.Services.AddScoped<Epic.Api.Auth.ICurrentUser, Epic.Api.Auth.ClaimsCurrentUser>();
else
    builder.Services.AddScoped<Epic.Api.Auth.ICurrentUser, Epic.Api.Auth.DevCurrentUser>();
builder.Services.AddScoped<Epic.Api.Auth.IAuditLog, Epic.Api.Auth.AuditLog>();
// GitHub origins (org + host + PAT) EPIC can read from — one, or several for
// multi-org/Enterprise setups. Singleton: derived once from configuration.
builder.Services.AddSingleton<IGitHubSourceRegistry, GitHubSourceRegistry>();
builder.Services.AddHttpClient<IGitHubService, GitHubService>(c => c.Timeout = TimeSpan.FromSeconds(60));
builder.Services.AddHttpClient<IAdoService, AdoService>(c =>
{
    c.Timeout = TimeSpan.FromSeconds(60);
    // Azure DevOps throttles unidentified traffic first (lower TSTU budget) and
    // asks all clients to send a User-Agent — sending a stable one is the cheapest
    // 429 mitigation. Accept keeps the JSON responses explicit.
    c.DefaultRequestHeaders.UserAgent.Add(new System.Net.Http.Headers.ProductInfoHeaderValue("EPIC-API", "1.0"));
    c.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
})
    // Retry-only resilience: retries transient failures (5xx, 408) and, crucially,
    // 429 throttling — honoring ADO's Retry-After header (ShouldRetryAfterHeader).
    // Deliberately NOT AddStandardResilienceHandler: its circuit breaker throws
    // BrokenCircuitException, which would break AdoService's "return null / serve
    // stale on failure" contract. A retry strategy returns the final response, so
    // the existing IsSuccessStatusCode handling stays intact.
    .AddResilienceHandler("ado-retry", b => b.AddRetry(new HttpRetryStrategyOptions
    {
        ShouldHandle = new PredicateBuilder<HttpResponseMessage>()
            .HandleResult(r => r.StatusCode is System.Net.HttpStatusCode.TooManyRequests
                or System.Net.HttpStatusCode.RequestTimeout
                or >= System.Net.HttpStatusCode.InternalServerError)
            .Handle<HttpRequestException>(),
        MaxRetryAttempts = 3,
        BackoffType = DelayBackoffType.Exponential,
        UseJitter = true,
        Delay = TimeSpan.FromSeconds(1),
        // Respect ADO's Retry-After (seconds or HTTP-date) when present, overriding
        // the computed backoff so we wait exactly as long as the server asks.
        ShouldRetryAfterHeader = true,
    }));
builder.Services.AddScoped<IAppService, AppService>();

// ---------------------------------------------------------------------------
// Build & Configure
// ---------------------------------------------------------------------------
var app = builder.Build();

// Apply pending EF Core migrations on startup (idempotent).
// Set EPIC_RUN_MIGRATIONS=false on additional instances to avoid concurrent migrate races.
//
// Retry with backoff so a transient DB blip at boot (e.g. a rotation landing
// exactly at startup, or Aurora Serverless resuming from zero) doesn't throw out
// of Program before app.RunAsync() — which would leave the process not listening
// at all, so even the [AllowAnonymous] /api/health probe can't answer. With
// retries a cold DB delays startup instead of killing it.
var runMigrations = !string.Equals(
    builder.Configuration["EPIC_RUN_MIGRATIONS"], "false", StringComparison.OrdinalIgnoreCase);
if (runMigrations)
{
    const int maxAttempts = 5;
    for (var attempt = 1; ; attempt++)
    {
        try
        {
            using var scope = app.Services.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<EpicDbContext>();
            await db.Database.MigrateAsync();
            break;
        }
        catch (Exception ex) when (attempt < maxAttempts)
        {
            var delay = TimeSpan.FromSeconds(Math.Pow(2, attempt)); // 2s, 4s, 8s, 16s
            app.Logger.LogWarning(ex,
                "Startup migration attempt {Attempt}/{MaxAttempts} failed; retrying in {Delay}s.",
                attempt, maxAttempts, delay.TotalSeconds);
            await Task.Delay(delay);
        }
    }
}

app.UseSwagger();
app.UseSwaggerUI();

app.UseCors("ApiCorsPolicy");
if (authEnabled)
    app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

await app.RunAsync();
