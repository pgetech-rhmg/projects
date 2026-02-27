using Xunit;

using Paige.Api.Engine.CfnConverter.Scan;
using Paige.Api.Engine.Common;

namespace Paige.Api.Tests.Engine.CfnConverter.Scan;

public sealed class CloudFormationTemplateLoaderTests
{
    // ============================================================
    // Null guard
    // ============================================================

    [Fact]
    public void Load_Throws_WhenFileIsNull()
    {
        Assert.Throws<ArgumentNullException>(() =>
            CloudFormationTemplateLoader.Load(null!));
    }

    // ============================================================
    // Unsupported extension
    // ============================================================

    [Fact]
    public void Load_ReturnsEmptyTemplate_ForUnsupportedExtension()
    {
        string path = CreateTempFile(".txt", "hello");

        try
        {
            var file = new ScannedFile { FullPath = path };

            var result = CloudFormationTemplateLoader.Load(file);

            Assert.Equal("txt", result.Format);
            Assert.Empty(result.RawTemplate);
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // JSON load + conversion coverage
    // ============================================================

    [Fact]
    public void Load_ParsesJson_AllValueKinds()
    {
        string path = CreateTempFile(".json", """
        {
          "StringProp": "value",
          "NumberProp": 123,
          "BoolTrue": true,
          "BoolFalse": false,
          "ObjectProp": { "Inner": "yes" },
          "ArrayProp": [1,2,3]
        }
        """);

        try
        {
            var file = new ScannedFile { FullPath = path };

            var result = CloudFormationTemplateLoader.Load(file);

            Assert.Equal("json", result.Format);
            Assert.NotNull(result.RawCfn);

            var dict = result.RawTemplate;

            Assert.Equal("value", dict["StringProp"]);
            Assert.Equal("123", dict["NumberProp"]); // number stored as raw text
            Assert.Equal(true, dict["BoolTrue"]);
            Assert.Equal(false, dict["BoolFalse"]);

            Assert.IsType<Dictionary<string, object?>>(dict["ObjectProp"]);
            Assert.NotNull(dict["ArrayProp"]); // JsonElement array
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // YAML mapping + scalar + sequence
    // ============================================================

    [Fact]
    public void Load_ParsesYaml_WithMappingAndSequence()
    {
        string path = CreateTempFile(".yaml", """
        Root:
          Key1: Value1
          List:
            - Item1
            - Item2
        """);

        try
        {
            var file = new ScannedFile { FullPath = path };

            var result = CloudFormationTemplateLoader.Load(file);

            Assert.Equal("yaml", result.Format);
            Assert.NotNull(result.RawCfn);

            var dict = result.RawTemplate;

            Assert.Contains("Root", dict);

            var rootMap = Assert.IsType<Dictionary<string, object?>>(dict["Root"]);
            Assert.Equal("Value1", rootMap["Key1"]);

            var list = Assert.IsType<List<object?>>(rootMap["List"]);
            Assert.Equal(2, list.Count);
            Assert.Equal("Item1", list[0]);
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // YAML empty document
    // ============================================================

    [Fact]
    public void LoadYaml_ReturnsEmptyTemplate_WhenNoDocuments()
    {
        string path = CreateTempFile(".yaml", "");

        try
        {
            var file = new ScannedFile { FullPath = path };

            var result = CloudFormationTemplateLoader.Load(file);

            Assert.Equal("yaml", result.Format);
            Assert.Empty(result.RawTemplate);
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // YAML invalid syntax (exception branch)
    // ============================================================

    [Fact]
    public void LoadYaml_ReturnsEmptyTemplate_WhenYamlInvalid()
    {
        string path = CreateTempFile(".yaml", ":::: invalid yaml :::");

        try
        {
            var file = new ScannedFile { FullPath = path };

            var result = CloudFormationTemplateLoader.Load(file);

            Assert.Equal("yaml", result.Format);
            Assert.Empty(result.RawTemplate);
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // YML extension coverage
    // ============================================================

    [Fact]
    public void Load_SupportsYmlExtension()
    {
        string path = CreateTempFile(".yml", "Key: Value");

        try
        {
            var file = new ScannedFile { FullPath = path };

            var result = CloudFormationTemplateLoader.Load(file);

            Assert.Equal("yaml", result.Format);
            Assert.NotEmpty(result.RawTemplate);
        }
        finally
        {
            File.Delete(path);
        }
    }

    // ============================================================
    // Helper
    // ============================================================

    private static string CreateTempFile(string extension, string content)
    {
        string path = Path.Combine(Path.GetTempPath(), Guid.NewGuid() + extension);
        File.WriteAllText(path, content);
        return path;
    }
}

