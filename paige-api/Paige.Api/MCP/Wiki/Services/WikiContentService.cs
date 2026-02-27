using System.Text;
using System.Text.RegularExpressions;
using HtmlAgilityPack;
using Paige.Api.MCP.Wiki.Models;

namespace Paige.Api.MCP.Wiki.Services;

public sealed class WikiContentService : IWikiContentService
{
    private readonly HttpClient _httpClient;

    public WikiContentService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<IReadOnlyList<WikiChunk>> FetchAndChunkAsync(
        string page,
        CancellationToken cancellationToken)
    {
        string urlDomain = "https://wiki.comp.pge.com";
        var html = await _httpClient.GetStringAsync($"{urlDomain}/{page}", cancellationToken);

        var doc = new HtmlDocument();
        doc.LoadHtml(html);

        // Remove noise
        var noiseNodes = doc.DocumentNode.SelectNodes(
            "//script|//style|//nav|//header|//footer"
        );

        if (noiseNodes != null)
        {
            foreach (var node in noiseNodes)
            {
                node.Remove();
            }
        }

        var extractedText = ExtractTextPreserveLinks($"{urlDomain}/{page}", doc.DocumentNode);
        var normalized = Normalize(extractedText);

        return Chunk(normalized);
    }

    private static string ExtractTextPreserveLinks(string baseUrl, HtmlNode node)
    {
        var sb = new StringBuilder();

        foreach (var child in node.ChildNodes)
        {
            AppendNodeContent(baseUrl, child, sb);
        }

        return HtmlEntity.DeEntitize(sb.ToString());
    }

    private static void AppendNodeContent(string baseUrl, HtmlNode node, StringBuilder sb)
    {
        var name = node.Name.ToLowerInvariant();

        switch (name)
        {
            case "#text":
                AppendTextNode(node, sb);
                break;

            case "a":
                AppendAnchorNode(baseUrl, node, sb);
                break;

            case "br":
            case "p":
            case "div":
            case "li":
            case "section":
                AppendBlockNode(baseUrl, node, sb);
                break;

            case "h1":
            case "h2":
            case "h3":
            case "h4":
            case "h5":
            case "h6":
                AppendHeadingNode(node, sb);
                break;

            default:
                AppendChildNodes(baseUrl, node, sb);
                break;
        }
    }

    private static void AppendTextNode(HtmlNode node, StringBuilder sb)
    {
        sb.Append(node.InnerText);
    }

    private static void AppendAnchorNode(string baseUrl, HtmlNode node, StringBuilder sb)
    {
        var linkText = node.InnerText.Trim();
        var href = node.GetAttributeValue("href", "");

        if (string.IsNullOrWhiteSpace(href))
        {
            sb.Append(linkText);
            return;
        }

        if (string.IsNullOrWhiteSpace(linkText))
        {
            sb.Append(href);
            return;
        }

        var fullUrl = href.StartsWith("http")
            ? href
            : $"{baseUrl}{href}";

        sb.Append($"{linkText} ({fullUrl})");
    }

    private static void AppendBlockNode(string baseUrl, HtmlNode node, StringBuilder sb)
    {
        sb.AppendLine();
        sb.Append(ExtractTextPreserveLinks(baseUrl, node));
        sb.AppendLine();
    }

    private static void AppendHeadingNode(HtmlNode node, StringBuilder sb)
    {
        sb.AppendLine();
        sb.Append(node.InnerText.Trim().ToUpperInvariant());
        sb.AppendLine();
    }

    private static void AppendChildNodes(string baseUrl, HtmlNode node, StringBuilder sb)
    {
        sb.Append(ExtractTextPreserveLinks(baseUrl, node));
    }

    private static string Normalize(string text)
    {
        return Regex.Replace(text, @"\s+", " ", RegexOptions.None,  TimeSpan.FromSeconds(30)).Trim();
    }

    private static IReadOnlyList<WikiChunk> Chunk(string text)
    {
        const int chunkSize = 80000;
        var chunks = new List<WikiChunk>();

        for (var i = 0; i < text.Length; i += chunkSize)
        {
            chunks.Add(new WikiChunk
            {
                Index = chunks.Count + 1,
                Text = text.Substring(i, Math.Min(chunkSize, text.Length - i)),
                CharacterCount = text.Length
            });
        }

        return chunks;
    }
}


