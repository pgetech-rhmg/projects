namespace Paige.Api.MCP.Wiki.Security;

public static class WikiUrlPolicy
{
    private static readonly string[] AllowedPrefixes =
    {
        "https://wiki.comp.pge.com/",
        "https://confluence.pge.com/"
    };

    public static bool IsAllowed(string url)
    {
        return AllowedPrefixes.Any(p =>
            url.StartsWith(p, StringComparison.OrdinalIgnoreCase));
    }
}

