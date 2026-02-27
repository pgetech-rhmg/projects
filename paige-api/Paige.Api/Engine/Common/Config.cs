namespace Paige.Api.Engine.Common;

public sealed class Config
{
    public string GithubBaseUrl { get; set; } = null!;

    public string GithubToken { get; set; } = null!;

    public string PortKeyBaseUrl { get; set; } = null!;

    public string PortKeyDefaultModel { get; set; } = null!;

    public string PortKeyClassifierModel { get; set; } = null!;

    public string PortKeyApiKey { get; set; } = null!;
}