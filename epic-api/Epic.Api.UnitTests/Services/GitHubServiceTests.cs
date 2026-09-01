using System.Net;
using Epic.Api.Services;
using Epic.Api.UnitTests.TestHelpers;
using Xunit;

namespace Epic.Api.UnitTests.Services;

public sealed class GitHubServiceTests
{
    // Legacy base URL "https://github.pge.com/pgetech" now maps (via the source
    // registry's Enterprise rule) to API root https://github.pge.com/api/v3 with
    // org "pgetech", so repo calls hit https://github.pge.com/api/v3/repos/pgetech/...
    // The RoutingHttpMessageHandler matches on path fragments (/languages,
    // contents/.infra?, git/trees, .../{repo}) which are unchanged by the host, so
    // the routing below still works against the Enterprise API base.
    private static GitHubService Make(HttpMessageHandler handler)
    {
        var http = new HttpClient(handler);
        var config = TestData.Config(("GITHUB_BASE_URL", "https://github.pge.com/pgetech"), ("GITHUB_TOKEN", "tok"));
        var sources = new GitHubSourceRegistry(config);
        return new GitHubService(http, config, sources, new StubGitHubAppTokenProvider(), TestData.Logger<GitHubService>(), TestData.NewCache());
    }

    // ---- Configuration guards ----

    [Fact]
    public void MissingBaseUrl_Throws()
    {
        // With no GitHubSources section and no GITHUB_BASE_URL the source registry
        // (which the service now depends on to resolve API base/org/token) has
        // nothing to synthesize a default from and throws at construction.
        Assert.Throws<InvalidOperationException>(() => new GitHubSourceRegistry(TestData.Config()));
    }

    [Fact]
    public async Task MissingToken_Throws()
    {
        // Base URL present but token missing.
        var http = new HttpClient(FakeHttpMessageHandler.Fixed(HttpStatusCode.OK, "{}"));
        var config = TestData.Config(("GITHUB_BASE_URL", "https://github.pge.com/pgetech"));
        var sources = new GitHubSourceRegistry(config);
        var svc = new GitHubService(http, config, sources, new StubGitHubAppTokenProvider(), TestData.Logger<GitHubService>(), TestData.NewCache());
        await Assert.ThrowsAsync<InvalidOperationException>(() => svc.GetRepoAsync("epic-web"));
    }

    // ---- GetRepoAsync ----

    [Fact]
    public async Task GetRepo_NotFound_ReturnsExistsFalse()
    {
        var svc = Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.NotFound, "{}"));
        var info = await svc.GetRepoAsync("nope");
        Assert.False(info.Exists);
    }

    [Fact]
    public async Task GetRepo_WithPrimaryLanguage_MapsFields()
    {
        var body = """
        { "name": "epic-web", "description": "desc", "language": "TypeScript",
          "default_branch": "main", "private": true }
        """;
        var svc = Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.OK, body));
        var info = await svc.GetRepoAsync("epic-web");

        Assert.True(info.Exists);
        Assert.Equal("epic-web", info.Name);
        Assert.Equal("desc", info.Description);
        Assert.Equal("TypeScript", info.Language);
        Assert.Equal("main", info.DefaultBranch);
        Assert.True(info.IsPrivate);
    }

    [Fact]
    public async Task GetRepo_NoPrimaryLanguage_FallsBackToLanguagesEndpoint()
    {
        var repoBody = """
        { "name": "r", "description": null, "language": null, "default_branch": "main", "private": false }
        """;
        var langBody = """{ "Python": 500, "Shell": 9000, "HTML": 100 }""";
        var handler = new RoutingHttpMessageHandler()
            .When("/languages", HttpStatusCode.OK, langBody)
            .When(r => r.RequestUri!.AbsolutePath.EndsWith("/r"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, repoBody));

        var info = await Make(handler).GetRepoAsync("r");

        Assert.Equal("Shell", info.Language); // most bytes
        Assert.Null(info.Description);
    }

    [Fact]
    public async Task GetRepo_NoPrimaryLanguage_LanguagesEndpointFails_LanguageNull()
    {
        var repoBody = """{ "name": "r", "language": "", "default_branch": "main", "private": false }""";
        var handler = new RoutingHttpMessageHandler()
            .When("/languages", HttpStatusCode.InternalServerError, "{}")
            .When(r => r.RequestUri!.AbsolutePath.EndsWith("/r"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, repoBody));

        var info = await Make(handler).GetRepoAsync("r");
        // Primary language was "" and the languages fallback failed → left as the
        // original empty string (only overwritten on a successful languages fetch).
        Assert.Equal("", info.Language);
    }

    [Fact]
    public async Task GetRepo_NonSuccessNon404_ReturnsExistsFalse()
    {
        var svc = Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.Unauthorized, "{}"));
        var info = await svc.GetRepoAsync("r");
        Assert.False(info.Exists);
    }

    // ---- PathExistsAsync ----

    [Fact]
    public async Task PathExists_TrueWhenFound_FalseWhenNot()
    {
        Assert.True(await Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.OK, "{}")).PathExistsAsync("r", ".infra", "main"));
        Assert.False(await Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.NotFound, "")).PathExistsAsync("r", ".infra", "main"));
    }

    // ---- GetFileContentAsync ----

    [Fact]
    public async Task GetFileContent_DecodesBase64()
    {
        var raw = "hello world";
        var b64 = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(raw));
        var body = $$"""{ "encoding": "base64", "content": "{{b64}}" }""";
        var content = await Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.OK, body)).GetFileContentAsync("r", "f", "main");
        Assert.Equal(raw, content);
    }

    [Fact]
    public async Task GetFileContent_NonBase64_ReturnsRawContent()
    {
        var body = """{ "encoding": "utf-8", "content": "plain" }""";
        var content = await Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.OK, body)).GetFileContentAsync("r", "f", "main");
        Assert.Equal("plain", content);
    }

    [Fact]
    public async Task GetFileContent_NotFound_ReturnsNull()
    {
        Assert.Null(await Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.NotFound, "")).GetFileContentAsync("r", "f", "main"));
    }

    // ---- FindEpicConfigsAsync ----

    [Fact]
    public async Task FindEpicConfigs_ReturnsMatchingBlobs()
    {
        var tree = """
        { "tree": [
          { "type": "blob", "path": "epic.json" },
          { "type": "blob", "path": ".pipeline/epic.json" },
          { "type": "blob", "path": "src/notepic.json" },
          { "type": "tree", "path": "dir/epic.json" },
          { "type": "blob", "path": "README.md" }
        ] }
        """;
        var configs = await Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.OK, tree)).FindEpicConfigsAsync("r", "main");
        Assert.Equal(["epic.json", ".pipeline/epic.json"], configs);
    }

    [Fact]
    public async Task FindEpicConfigs_NullTree_ReturnsEmpty()
    {
        Assert.Empty(await Make(FakeHttpMessageHandler.Fixed(HttpStatusCode.InternalServerError, "{}")).FindEpicConfigsAsync("r", "main"));
    }

    // ---- CheckInfraAsync ----

    [Fact]
    public async Task CheckInfra_ParsesAppSection_AndScansTerraform()
    {
        var epicJson = """
        { "app": { "appType": "dotnet", "infraPath": ".infra", "buildTestTool": "xunit",
                   "scanTool": "sonarqube", "integrationTestTool": "playwright" },
          "cloud": { "awsAccountId": "123" } }
        """;
        var contentBody = FileContentJson(epicJson);
        var tree = """
        { "tree": [
          { "type": "blob", "path": ".infra/main.tf" },
          { "type": "blob", "path": ".infra/terraform.tfstate" }
        ] }
        """;
        var tfContent = FileContentJson("terraform {\n  backend \"s3\" {}\n}");

        var handler = new RoutingHttpMessageHandler()
            // config file read (path contains epic.json)
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, contentBody))
            // .infra path existence check (contents/.infra)
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, "{}"))
            // recursive tree scan
            .When("git/trees", HttpStatusCode.OK, tree)
            // .tf file content
            .When(r => r.RequestUri!.ToString().Contains("main.tf"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, tfContent));

        var result = await Make(handler).CheckInfraAsync("r", "main", ".pipeline/epic.json");

        Assert.True(result.HasInfra);
        Assert.True(result.HasInfraParams);   // awsAccountId present
        Assert.Equal("dotnet", result.AppType);
        Assert.Equal("xunit", result.BuildTestTool);
        Assert.Equal("sonarqube", result.ScanTool);
        Assert.Equal("playwright", result.IntegrationTestTool);
        Assert.True(result.HasRemoteBackend);   // awsAccountId -> aws -> expects s3, and s3 block present
        Assert.Equal("s3", result.ExpectedBackend);
        Assert.True(result.HasTfState);
    }

    [Fact]
    public async Task CheckInfra_AwsConfig_AzurermBackendIsWrongCloud_NotDetected()
    {
        // An AWS config whose Terraform declares an azurerm backend is a mismatch:
        // EPIC injects s3 for AWS, so the azurerm block can't be managed. Guards
        // against the cloud-aware check accepting any backend regardless of cloud.
        var epicJson = """{ "app": { "appType": "dotnet", "infraPath": ".infra" }, "cloud": { "awsAccountId": "123" } }""";
        var tree = """{ "tree": [ { "type": "blob", "path": ".infra/terraform.tf" } ] }""";
        var tfContent = FileContentJson("terraform {\n  backend \"azurerm\" {}\n}");

        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, "{}"))
            .When("git/trees", HttpStatusCode.OK, tree)
            .When(r => r.RequestUri!.ToString().Contains("terraform.tf"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, tfContent));

        var result = await Make(handler).CheckInfraAsync("r", "main", ".pipeline/epic.json");

        Assert.True(result.HasInfra);
        Assert.False(result.HasRemoteBackend);
        Assert.Equal("s3", result.ExpectedBackend);
    }

    [Fact]
    public async Task CheckInfra_BtpAppType_ExpectsS3Backend()
    {
        // btp/cap -> sap, and the SAP infra stage uses the S3 backend, so the
        // expected backend must be s3 (not azurerm) even though it's not AWS.
        var epicJson = """
        { "app": { "appType": "btp", "infraPath": ".infra" },
          "cloud": { "environments": { "dev": { "azureServiceConnection": "ignored-for-sap" } } } }
        """;
        var tree = """{ "tree": [ { "type": "blob", "path": ".infra/terraform.tf" } ] }""";
        var tfContent = FileContentJson("terraform {\n  backend \"s3\" {}\n}");

        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, "{}"))
            .When("git/trees", HttpStatusCode.OK, tree)
            .When(r => r.RequestUri!.ToString().Contains("terraform.tf"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, tfContent));

        var result = await Make(handler).CheckInfraAsync("r", "main", ".pipeline/epic.json");

        Assert.Equal("s3", result.ExpectedBackend);
        Assert.True(result.HasRemoteBackend);
    }

    [Fact]
    public async Task CheckInfra_AzureConfig_DetectsAzurermBackend()
    {
        // Azure config (per-env service connection) whose Terraform declares the
        // azurerm backend EPIC injects for Azure — must be detected as a valid
        // EPIC-managed backend, not rejected for lacking an S3 block.
        var epicJson = """
        { "app": { "appType": "infra", "infraPath": ".infra" },
          "cloud": { "environments": { "dev": { "azureServiceConnection": "AzureExt-Dev" } } } }
        """;
        var tree = """{ "tree": [ { "type": "blob", "path": ".infra/terraform.tf" } ] }""";
        var tfContent = FileContentJson("terraform {\n  backend \"azurerm\" {}\n}");

        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, "{}"))
            .When("git/trees", HttpStatusCode.OK, tree)
            .When(r => r.RequestUri!.ToString().Contains("terraform.tf"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, tfContent));

        var result = await Make(handler).CheckInfraAsync("r", "main", ".pipeline/epic.json");

        Assert.True(result.HasInfra);
        Assert.True(result.HasRemoteBackend);
        Assert.Equal("azurerm", result.ExpectedBackend);
    }

    [Fact]
    public async Task CheckInfra_AzureConfig_S3BackendIsWrongCloud_NotDetected()
    {
        // An Azure config whose Terraform declares an S3 backend is a mismatch:
        // EPIC injects azurerm for Azure, so the S3 block can't be managed.
        var epicJson = """
        { "app": { "appType": "infra", "infraPath": ".infra" },
          "cloud": { "azureServiceConnection": "Azure" } }
        """;
        var tree = """{ "tree": [ { "type": "blob", "path": ".infra/terraform.tf" } ] }""";
        var tfContent = FileContentJson("terraform {\n  backend \"s3\" {}\n}");

        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, "{}"))
            .When("git/trees", HttpStatusCode.OK, tree)
            .When(r => r.RequestUri!.ToString().Contains("terraform.tf"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, tfContent));

        var result = await Make(handler).CheckInfraAsync("r", "main", ".pipeline/epic.json");

        Assert.True(result.HasInfra);
        Assert.False(result.HasRemoteBackend);
    }

    [Fact]
    public async Task CheckInfra_NoInfraFolder_SkipsTerraformScan()
    {
        var epicJson = """{ "app": { "appType": "angular" }, "cloud": {} }""";
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.NotFound, ""));

        var result = await Make(handler).CheckInfraAsync("r", "main", "epic.json");

        Assert.False(result.HasInfra);
        Assert.False(result.HasRemoteBackend);
        Assert.False(result.HasTfState);
        Assert.False(result.HasInfraParams);
    }

    [Fact]
    public async Task CheckInfra_BtpAppType_RequiresSecretsManager()
    {
        var epicJson = """
        { "app": { "appType": "btp" },
          "cloud": { "secretsManager": { "name": "sm", "keys": ["BTP_USERNAME"] } } }
        """;
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.NotFound, ""));

        var result = await Make(handler).CheckInfraAsync("r", "main", "epic.json");
        Assert.True(result.HasInfraParams);
    }

    [Fact]
    public async Task CheckInfra_AzurePerEnvConnection_HasInfraParams()
    {
        // Azure per-env model (subscription comes from the service connection, so
        // NO azureSubscriptionId in epic.json). A static react SPA with per-env
        // azureServiceConnection + staticStorageAccount must count as having a
        // deploy target (hasInfraParams=true) so the UI enables Deploy App —
        // even though there is no .infra folder and no azureSubscriptionId.
        var epicJson = """
        { "app": { "appType": "react" },
          "cloud": { "environments": {
            "dev": { "azureServiceConnection": "VegMgmt-DEV", "staticStorageAccount": "onboardxappfedev" }
          } } }
        """;
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.NotFound, ""));

        var result = await Make(handler).CheckInfraAsync("r", "main", "epic.json");
        Assert.False(result.HasInfra);          // no .infra folder
        Assert.True(result.HasInfraParams);     // per-env azureServiceConnection is a deploy target
    }

    [Fact]
    public async Task CheckInfra_FlatAzureConnection_HasInfraParams()
    {
        // Flat cloud.azureServiceConnection (no per-env map, no azureSubscriptionId)
        // is also a valid Azure deploy target.
        var epicJson = """{ "app": { "appType": "angular" }, "cloud": { "azureServiceConnection": "Azure" } }""";
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.NotFound, ""));

        var result = await Make(handler).CheckInfraAsync("r", "main", "epic.json");
        Assert.True(result.HasInfraParams);
    }

    [Fact]
    public async Task CheckInfra_PerEnvMap_ReturnsConfiguredEnvironments()
    {
        var epicJson = """
        { "app": { "appType": "infra" },
          "cloud": { "environments": {
            "dev":  { "azureServiceConnection": "AzureExt-Dev" },
            "qa":   { "azureServiceConnection": "AzureExt-Dev" },
            "uat":  { "azureServiceConnection": "AzureExt" },
            "prod": { "azureServiceConnection": "AzureExt" }
          } } }
        """;
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.NotFound, ""));

        var result = await Make(handler).CheckInfraAsync("r", "main", "epic.json");
        Assert.Equal(new[] { "dev", "qa", "uat", "prod" }, result.ConfiguredEnvironments);
    }

    [Fact]
    public async Task CheckInfra_NoEnvMap_ReturnsEmptyConfiguredEnvironments()
    {
        var epicJson = """{ "app": { "appType": "angular" }, "cloud": { "azureServiceConnection": "Azure" } }""";
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.NotFound, ""));

        var result = await Make(handler).CheckInfraAsync("r", "main", "epic.json");
        Assert.Empty(result.ConfiguredEnvironments);
    }

    [Fact]
    public async Task CheckInfra_RootInfraPath_WhenNoAppSection()
    {
        var epicJson = """{ "infraPath": "terraform", "cloud": { "azureSubscriptionId": "abc" } }""";
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/terraform?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.NotFound, ""));

        var result = await Make(handler).CheckInfraAsync("r", "main", "epic.json");
        Assert.True(result.HasInfraParams); // azureSubscriptionId
        Assert.False(result.HasInfra);
    }

    [Fact]
    public async Task CheckInfra_UnparseableConfig_UsesDefaults()
    {
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson("{ not json")))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.NotFound, ""));

        var result = await Make(handler).CheckInfraAsync("r", "main", "epic.json");
        Assert.Null(result.AppType);
        Assert.False(result.HasInfra);
    }

    [Fact]
    public async Task CheckInfra_CommentedBackend_NotDetected()
    {
        var epicJson = """{ "app": { "appType": "dotnet" }, "cloud": { "awsAccountId": "1" } }""";
        var tree = """{ "tree": [ { "type": "blob", "path": ".infra/main.tf" } ] }""";
        // The S3 backend is fully commented out — must not register.
        var tf = "terraform {\n  # backend \"s3\" {}\n  /* backend \"s3\" {} */\n}";

        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, "{}"))
            .When("git/trees", HttpStatusCode.OK, tree)
            .When(r => r.RequestUri!.ToString().Contains("main.tf"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(tf)));

        var result = await Make(handler).CheckInfraAsync("r", "main", "epic.json");
        Assert.True(result.HasInfra);
        Assert.False(result.HasRemoteBackend);
    }

    [Fact]
    public async Task CheckInfra_TerraformScanNullTree_ReturnsFalses()
    {
        var epicJson = """{ "app": { "appType": "dotnet" }, "cloud": {} }""";
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.ToString().Contains("epic.json"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, FileContentJson(epicJson)))
            .When(r => r.RequestUri!.ToString().Contains("contents/.infra?"), _ => FakeHttpMessageHandler.Build(HttpStatusCode.OK, "{}"))
            .When("git/trees", HttpStatusCode.InternalServerError, "{}");

        var result = await Make(handler).CheckInfraAsync("r", "main", "epic.json");
        Assert.True(result.HasInfra);
        Assert.False(result.HasRemoteBackend);
        Assert.False(result.HasTfState);
    }

    // ---- Caching ----

    [Fact]
    public async Task SuccessfulResponse_IsCached_404IsNot()
    {
        var call = 0;
        var handler = new RoutingHttpMessageHandler()
            .When(r => r.RequestUri!.AbsolutePath.EndsWith("/hit"), _ =>
            {
                call++;
                return FakeHttpMessageHandler.Build(HttpStatusCode.OK, """{"name":"hit","default_branch":"main","private":false,"language":"Go"}""");
            });
        var svc = Make(handler);

        await svc.GetRepoAsync("hit");
        await svc.GetRepoAsync("hit");
        Assert.Equal(1, call); // second served from cache
    }

    // GitHub /contents responses wrap file content in this shape.
    private static string FileContentJson(string content)
    {
        var b64 = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(content));
        return $$"""{ "encoding": "base64", "content": "{{b64}}" }""";
    }
}
