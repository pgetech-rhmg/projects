# Confluence-to-Terraform MCP Server

MCP server that crawls PG&E's internal Confluence wiki and provides searchable, chunked content optimized for AI-assisted CloudFormation-to-Terraform conversions.

## Architecture

```
Confluence REST API
        |
        v
   ConfluenceCrawler     -- Recursive page fetcher via REST API
        |
        v
   ContentChunker         -- Splits pages into ~1500 token chunks with overlap
        |
        v
   KnowledgeBase (JSON)   -- Persisted to disk, loaded at MCP server startup
        |
        v
   FastMCP Server          -- Exposes search/retrieve/list/stats/crawl tools
        |
        v
   Claude Code / Desktop   -- Consumes tools for CF-to-TF conversion context
```

## Setup

```bash
# Clone and install
cd confluence-tf-mcp
pip install -e .

# Set environment variables
export CONFLUENCE_BASE_URL="https://wiki.comp.pge.com"
export CONFLUENCE_PAT_TOKEN="your-pat-token"
export CONFLUENCE_ROOT_PAGE_ID="your-root-page-id"
```

## Usage

### 1. Pre-build the knowledge base (recommended)

```bash
# Crawl and build the KB file before starting the server
python -m confluence_tf_mcp crawl --root-page-id YOUR_PAGE_ID

# Check what you got
python -m confluence_tf_mcp stats

# Test a search
python -m confluence_tf_mcp search "EC2 instance security group"
```

### 2. Run the MCP server

```bash
# stdio transport (for Claude Code / Claude Desktop)
python -m confluence_tf_mcp.server

# Or via the installed script
confluence-tf-mcp
```

### 3. Configure Claude Code / Claude Desktop

Copy `mcp_config.json` to your Claude config directory and update the paths and credentials.

For Claude Code, add to `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "confluence_tf_mcp": {
      "command": "python",
      "args": ["-m", "confluence_tf_mcp.server"],
      "env": {
        "CONFLUENCE_BASE_URL": "https://wiki.comp.pge.com",
        "CONFLUENCE_PAT_TOKEN": "your-token",
        "CONFLUENCE_ROOT_PAGE_ID": "your-page-id",
        "KB_PATH": "/path/to/knowledge_base.json"
      },
      "cwd": "/path/to/confluence-tf-mcp/src"
    }
  }
}
```

## MCP Tools

| Tool | Description |
|------|-------------|
| `confluence_search` | Keyword search across all chunked content. Supports label filtering. |
| `confluence_get_page` | Retrieve full content of a specific page by ID. |
| `confluence_list_pages` | List all pages with metadata, labels, chunk counts. Supports pagination. |
| `confluence_kb_stats` | Knowledge base statistics: page/chunk/token counts, label distribution. |
| `confluence_crawl` | Trigger a fresh crawl from a root page ID. Rebuilds the KB. |

## Chunking Strategy

Pages are split into ~1500 token chunks (configurable):

1. Split on section headings first
2. Fall back to paragraph boundaries
3. Merge fragments under 200 tokens
4. Add 150-token overlap between adjacent chunks for continuity
5. Each chunk gets a metadata header (page title, URL, labels, chunk position)

This ensures every chunk the LLM sees has enough context to be useful on its own.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CONFLUENCE_BASE_URL` | `https://wiki.comp.pge.com` | Confluence instance URL |
| `CONFLUENCE_PAT_TOKEN` | (required) | Personal Access Token |
| `CONFLUENCE_ROOT_PAGE_ID` | (required) | Starting page for crawl |
| `KB_PATH` | `./knowledge_base.json` | Knowledge base file path |

## Generating a Confluence PAT Token

1. Log into Confluence (https://wiki.comp.pge.com)
2. Click your profile icon -> Settings
3. Personal Access Tokens -> Create Token
4. Give it a name, set expiry, and copy the token

If PAT tokens aren't available in your Confluence instance (some Data Center versions), you can use basic auth by modifying the crawler to accept username/password.
