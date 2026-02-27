using System;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Paige.Api.Engine.Chat;
using Paige.Api.Engine.Common;
using Paige.Api.Engine.RepoAssessment;
using Paige.Api.MCP.Wiki.Services;
using Paige.Api.Packs;

using Xunit;

namespace Paige.Api.UnitTests;

public sealed class ProgramTests
{
    private static void SetRequiredEnvironmentVariables()
    {
        Environment.SetEnvironmentVariable("GITHUB_BASE_URL", "https://github.com");
        Environment.SetEnvironmentVariable("PORTKEY_BASE_URL", "https://portkey.ai");
        Environment.SetEnvironmentVariable("PORTKEY_MODEL", "model");
        Environment.SetEnvironmentVariable("PORTKEY_MODEL_CLASSIFIER", "classifier-model");
        Environment.SetEnvironmentVariable("PORTKEY_API_KEY", "apikey");
    }

    // -------------------------------------------------------------------------
    // App builds successfully
    // -------------------------------------------------------------------------

    [Fact]
    public async Task Program_Should_Build_And_Register_Services()
    {
        SetRequiredEnvironmentVariables();

        await using var factory = new WebApplicationFactory<Program>();

        var client = factory.CreateClient();

        var scope = factory.Services.CreateScope();
        var services = scope.ServiceProvider;

        // Config bound
        var config = services.GetRequiredService<IOptions<Config>>().Value;

        Assert.Equal("https://github.com", config.GithubBaseUrl);
        Assert.Equal("classifier-model", config.PortKeyClassifierModel);

        // Core services registered
        Assert.NotNull(services.GetService<IPackClassificationService>());
        Assert.NotNull(services.GetService<ChatExecutionService>());
        Assert.NotNull(services.GetService<IRepoAssessmentService>());
        Assert.NotNull(services.GetService<IWikiContentService>());
    }

    // -------------------------------------------------------------------------
    // Missing required config throws
    // -------------------------------------------------------------------------

    [Fact]
    public void Program_Should_Throw_When_Config_Missing()
    {
        Environment.SetEnvironmentVariable("GITHUB_BASE_URL", null);
        Environment.SetEnvironmentVariable("PORTKEY_BASE_URL", null);
        Environment.SetEnvironmentVariable("PORTKEY_MODEL", null);
        Environment.SetEnvironmentVariable("PORTKEY_MODEL_CLASSIFIER", null);
        Environment.SetEnvironmentVariable("PORTKEY_API_KEY", null);

        using var factory = new WebApplicationFactory<Program>();

        var ex = Assert.Throws<InvalidOperationException>(() =>
        {
            using var scope = factory.Services.CreateScope();
            _ = scope.ServiceProvider
                .GetRequiredService<IOptions<Config>>()
                .Value; // 🔥 forces Configure<Config> execution
        });

        Assert.Contains("is not set", ex.Message);
    }

    // -------------------------------------------------------------------------
    // CORS policy exists
    // -------------------------------------------------------------------------

    [Fact]
    public async Task Program_Should_Register_CorsPolicy()
    {
        SetRequiredEnvironmentVariables();

        await using var factory = new WebApplicationFactory<Program>();

        var services = factory.Services;

        var corsOptions = services.GetService<
            Microsoft.Extensions.Options.IOptions<
                Microsoft.AspNetCore.Cors.Infrastructure.CorsOptions>>();

        Assert.NotNull(corsOptions);
    }

    // -------------------------------------------------------------------------
    // Context packs registered as singleton
    // -------------------------------------------------------------------------

    [Fact]
    public async Task Program_Should_Register_ContextPacks()
    {
        SetRequiredEnvironmentVariables();

        await using var factory = new WebApplicationFactory<Program>();

        var packs = factory.Services.GetService<IReadOnlyCollection<IContextPack>>();

        Assert.NotNull(packs);
    }
}

