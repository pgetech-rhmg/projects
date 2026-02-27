using Amazon.SecretsManager;
using Amazon.SecretsManager.Model;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.ResponseCompression;

using Paige.Api.Engine.CfnConverter.Cfn;
using Paige.Api.Engine.CfnConverter.Terraform;
using Paige.Api.Engine.Chat;
using Paige.Api.Packs;
using Paige.Api.Engine.Common;
using Paige.Api.Engine.RepoAssessment;
using Paige.Api.Engine.PortKey;
using Paige.Api.Engine.CfnConverter.Scan;
using Paige.Api.MCP.Wiki.Services;
using Paige.Api.Engine.RepoAssessment.Ai;

using System.Text.Json;
using Amazon;
using Amazon.Extensions.NETCore.Setup;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration
    .AddJsonFile("appsettings.json", optional: false)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true)
    .AddEnvironmentVariables();


// ------------------------------------------------------------
// AWS Secrets Manager (ONLY when NOT local/dev)
// ------------------------------------------------------------

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

    builder.Configuration.AddInMemoryCollection(secrets);
}


// ------------------------------------------------------------
// Bind Config
// ------------------------------------------------------------

builder.Services.Configure<Config>(options =>
{
    options.GithubBaseUrl =
        builder.Configuration["GITHUB_BASE_URL"]
        ?? throw new InvalidOperationException("Github:BaseUrl is not set.");

    options.GithubToken =
        builder.Configuration["GITHUB_TOKEN"]
        ?? throw new InvalidOperationException("Github:Token is not set.");

    options.PortKeyBaseUrl =
        builder.Configuration["PORTKEY_BASE_URL"]
        ?? throw new InvalidOperationException("PortKey:BaseUrl is not set.");

    options.PortKeyDefaultModel =
        builder.Configuration["PORTKEY_MODEL"]
        ?? throw new InvalidOperationException("PortKey:DefaultModel is not set.");

    options.PortKeyClassifierModel =
        builder.Configuration["PORTKEY_MODEL_CLASSIFIER"]
        ?? throw new InvalidOperationException("PortKey:ClassifierModel is not set.");

    options.PortKeyApiKey =
        builder.Configuration["PORTKEY_API_KEY"]
        ?? throw new InvalidOperationException("PortKey:ApiKey is not set.");
});

builder.Services.AddCors(options =>
{
    options.AddPolicy(name: "ApiCorsPolicy",
        policy =>
        {
            policy.WithOrigins("https://paige-dev.nonprod.pge.com", "http://localhost:4200", "https://localhost:4200")
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
});

builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;

    options.MimeTypes = ResponseCompressionDefaults.MimeTypes
        .Where(m => m != "text/event-stream");
});

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new()
    {
        Title = "PAIGE API",
        Version = "v1",
        Description = "PG&E AI for Innovation, Governance, and Engineering"
    });
});

builder.Services.AddHttpClient<IWikiContentService, WikiContentService>();
builder.Services.AddScoped<IWikiContentService, WikiContentService>();

builder.Services.AddHttpClient<IPortKeyExecutionService, PortKeyExecutionService>(client =>
{
    client.Timeout = TimeSpan.FromMinutes(5);
});

builder.Services.AddScoped<IRepoScanService, RepoScanService>();
builder.Services.AddScoped<IRepoCloner, RepoCloner>();
builder.Services.AddScoped<IFileScanner, FileScanner>();
builder.Services.AddScoped<RepositoryGraphBuilder>();

builder.Services.AddScoped<ICloudFormationDetector, CloudFormationDetector>();
builder.Services.AddScoped<ICloudFormationClassifier, CloudFormationClassifier>();

builder.Services.AddScoped<CfnExecutionService>();
builder.Services.AddScoped<ChatExecutionService>();

builder.Services.AddScoped<IRepoAssessmentService, RepoAssessmentService>();
builder.Services.AddScoped<RepoAssessmentAiService>();
builder.Services.AddScoped<IRepoStructureAnalyzer, RepoStructureAnalyzer>();

builder.Services.AddScoped<TerraformProjectBuilder>();

var allPacks = ContextPackDiscovery.DiscoverAllPacks();
builder.Services.AddSingleton<IReadOnlyCollection<IContextPack>>(allPacks);
builder.Services.AddSingleton<BaselinePackLoader>();
builder.Services.AddSingleton<BaselinePromptProvider>();

builder.Services.AddScoped<PackScoringService>();
builder.Services.AddScoped<PromptComposer>();
builder.Services.AddScoped<IPackClassificationService, PackClassificationService>();

builder.Services
    .AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(
            new System.Text.Json.Serialization.JsonStringEnumConverter());
    });

var app = builder.Build();

app.UseCors("ApiCorsPolicy");
app.UseResponseCompression();

app.UseSwagger();
app.UseSwaggerUI(options =>
{
    options.DocumentTitle = "PAIGE API";
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "PAIGE API v1");
});

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

await app.RunAsync();

public partial class Program { }
