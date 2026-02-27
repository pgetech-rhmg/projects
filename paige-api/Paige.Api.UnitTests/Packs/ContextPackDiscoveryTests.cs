using System;
using System.IO;
using System.Linq;
using System.Text.Json;

using Paige.Api.Packs;

using Xunit;

namespace Paige.Api.UnitTests.Packs;

public sealed class ContextPackDiscoveryTests : IDisposable
{
    private readonly string _basePath;

    public ContextPackDiscoveryTests()
    {
        _basePath = Path.Combine(
            AppContext.BaseDirectory,
            "Packs",
            "Context");

        if (Directory.Exists(_basePath))
        {
            Directory.Delete(_basePath, true);
        }
    }

    // -------------------------------------------------------------------------
    // Directory does not exist
    // -------------------------------------------------------------------------

    [Fact]
    public void DiscoverAllPacks_Should_Return_Empty_When_Directory_Missing()
    {
        var packs = ContextPackDiscovery.DiscoverAllPacks();

        Assert.Empty(packs);
    }

    // -------------------------------------------------------------------------
    // Directory exists but empty
    // -------------------------------------------------------------------------

    [Fact]
    public void DiscoverAllPacks_Should_Return_Empty_When_No_Json_Files()
    {
        Directory.CreateDirectory(_basePath);

        var packs = ContextPackDiscovery.DiscoverAllPacks();

        Assert.Empty(packs);
    }

    // -------------------------------------------------------------------------
    // Invalid JSON
    // -------------------------------------------------------------------------

    [Fact]
    public void DiscoverAllPacks_Should_Throw_On_Invalid_Json()
    {
        Directory.CreateDirectory(_basePath);

        File.WriteAllText(
            Path.Combine(_basePath, "invalid.json"),
            "{ invalid json }");

        Assert.Throws<JsonException>(() =>
            ContextPackDiscovery.DiscoverAllPacks());
    }

    // -------------------------------------------------------------------------
    // Missing Metadata
    // -------------------------------------------------------------------------

    [Fact]
    public void DiscoverAllPacks_Should_Skip_When_Metadata_Null()
    {
        Directory.CreateDirectory(_basePath);

        var json = """
        {
            "Prompt": "test prompt"
        }
        """;

        File.WriteAllText(
            Path.Combine(_basePath, "missingMetadata.json"),
            json);

        var packs = ContextPackDiscovery.DiscoverAllPacks();

        Assert.Empty(packs);
    }

    // -------------------------------------------------------------------------
    // Empty Prompt
    // -------------------------------------------------------------------------

    [Fact]
    public void DiscoverAllPacks_Should_Skip_When_Prompt_Empty()
    {
        Directory.CreateDirectory(_basePath);

        var json = """
        {
            "Metadata": { "PackId": "id" },
            "Prompt": ""
        }
        """;

        File.WriteAllText(
            Path.Combine(_basePath, "emptyPrompt.json"),
            json);

        var packs = ContextPackDiscovery.DiscoverAllPacks();

        Assert.Empty(packs);
    }

    // -------------------------------------------------------------------------
    // Valid JSON
    // -------------------------------------------------------------------------

    [Fact]
    public void DiscoverAllPacks_Should_Return_Valid_Pack()
    {
        Directory.CreateDirectory(_basePath);

        var json = """
        {
            "Metadata": {
                "PackId": "id",
                "Version": "1.0"
            },
            "Prompt": "test prompt"
        }
        """;

        File.WriteAllText(
            Path.Combine(_basePath, "valid.json"),
            json);

        var packs = ContextPackDiscovery.DiscoverAllPacks();

        Assert.Single(packs);

        var pack = packs.First();

        Assert.NotNull(pack);
    }

    // -------------------------------------------------------------------------
    // Cleanup
    // -------------------------------------------------------------------------

    public void Dispose()
    {
        if (Directory.Exists(_basePath))
        {
            Directory.Delete(_basePath, true);
        }
    }
}

