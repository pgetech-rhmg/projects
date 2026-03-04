#!/usr/bin/env python3
"""Confluence-to-Terraform MCP Server.

Read-only MCP server that loads a pre-built knowledge base and exposes
search/query tools for AI-assisted CloudFormation-to-Terraform conversion.
"""

from __future__ import annotations

import json
import logging
import os
import sys
from contextlib import asynccontextmanager
from enum import Enum
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, Request
from fastapi.responses import PlainTextResponse
from mcp.server import Server
from mcp.server.sse import SseServerTransport
from mcp.types import Tool, TextContent

from .models import ContentChunk, KnowledgeBase

logger = logging.getLogger(__name__)

KB_PATH = Path(os.environ.get("KB_PATH", Path(__file__).parent / "knowledge_base.json"))

# Global KB instance
_kb: Optional[KnowledgeBase] = None


def _load_kb() -> KnowledgeBase:
	if not KB_PATH.exists():
		raise FileNotFoundError(f"Knowledge base not found at {KB_PATH}")
	with open(KB_PATH) as f:
		return KnowledgeBase.model_validate(json.load(f))


def _search_chunks(chunks: list[ContentChunk], query: str, labels: Optional[list[str]] = None, limit: int = 10) -> list[ContentChunk]:
	query_terms = query.lower().split()
	scored: list[tuple[float, ContentChunk]] = []
	for chunk in chunks:
		score = 0.0
		for term in query_terms:
			if term in chunk.page_title.lower():
				score += 3.0
			score += chunk.content.lower().count(term)
		if labels:
			if not any(l.lower() in {cl.lower() for cl in chunk.labels} for l in labels):
				continue
		if score > 0:
			scored.append((score, chunk))
	scored.sort(key=lambda x: x[0], reverse=True)
	return [c for _, c in scored[:limit]]


# ── Models ───────────────────────────────────────────────────────────────────

class ResponseFormat(str, Enum):
	MARKDOWN = "markdown"
	JSON = "json"


def _fmt_md(chunks: list[ContentChunk]) -> str:
	return "\n\n".join(c.content for c in chunks) if chunks else "No results found."


def _fmt_json(chunks: list[ContentChunk]) -> str:
	return json.dumps([c.model_dump(exclude={"labels"}) for c in chunks], indent=2, default=str)


# ── MCP Server Setup ─────────────────────────────────────────────────────────

mcp_server = Server("confluence_tf_mcp")


@mcp_server.list_tools()
async def list_tools() -> list[Tool]:
	return [
		Tool(
			name="confluence_search",
			description="Search the knowledge base for CloudFormation/Terraform content.",
			inputSchema={
				"type": "object",
				"properties": {
					"query": {"type": "string", "description": "Search terms: CF resource types, TF resources, or keywords", "minLength": 2, "maxLength": 500},
					"labels": {"type": "array", "items": {"type": "string"}, "description": "Filter by page labels"},
					"limit": {"type": "integer", "default": 10, "minimum": 1, "maximum": 50},
					"response_format": {"type": "string", "enum": ["markdown", "json"], "default": "markdown"}
				},
				"required": ["query"]
			}
		),
		Tool(
			name="confluence_get_page",
			description="Get the full content of a specific page by ID.",
			inputSchema={
				"type": "object",
				"properties": {
					"page_id": {"type": "string", "description": "Confluence page ID", "minLength": 1},
					"response_format": {"type": "string", "enum": ["markdown", "json"], "default": "markdown"}
				},
				"required": ["page_id"]
			}
		),
		Tool(
			name="confluence_list_pages",
			description="List pages in the knowledge base.",
			inputSchema={
				"type": "object",
				"properties": {
					"labels": {"type": "array", "items": {"type": "string"}, "description": "Filter by labels"},
					"limit": {"type": "integer", "default": 50, "minimum": 1, "maximum": 200},
					"offset": {"type": "integer", "default": 0, "minimum": 0},
					"response_format": {"type": "string", "enum": ["markdown", "json"], "default": "markdown"}
				}
			}
		),
		Tool(
			name="confluence_kb_stats",
			description="Get knowledge base statistics.",
			inputSchema={"type": "object", "properties": {}}
		)
	]


@mcp_server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
	global _kb
	
	if name == "confluence_search":
		results = _search_chunks(
			_kb.chunks,
			arguments["query"],
			arguments.get("labels"),
			arguments.get("limit", 10)
		)
		if not results:
			text = f"No results for '{arguments['query']}'."
		elif arguments.get("response_format") == "json":
			text = _fmt_json(results)
		else:
			text = f"## Search: '{arguments['query']}' ({len(results)} results)\n\n" + _fmt_md(results)
		return [TextContent(type="text", text=text)]
	
	elif name == "confluence_get_page":
		page_id = arguments["page_id"]
		chunks = sorted([c for c in _kb.chunks if c.page_id == page_id], key=lambda c: c.chunk_index)
		if not chunks:
			text = f"Page '{_kb.pages[page_id].title}' has no content." if page_id in _kb.pages else f"Page '{page_id}' not found."
		elif arguments.get("response_format") == "json":
			text = _fmt_json(chunks)
		else:
			text = _fmt_md(chunks)
		return [TextContent(type="text", text=text)]
	
	elif name == "confluence_list_pages":
		pages = list(_kb.pages.values())
		if arguments.get("labels"):
			ls = {l.lower() for l in arguments["labels"]}
			pages = [p for p in pages if any(l.lower() in ls for l in p.labels)]
		total = len(pages)
		offset = arguments.get("offset", 0)
		limit = arguments.get("limit", 50)
		pages = pages[offset:offset + limit]
		
		if arguments.get("response_format") == "json":
			text = json.dumps({
				"total": total, "count": len(pages), "offset": offset,
				"pages": [{"id": p.id, "title": p.title, "url": p.url, "chunks": sum(1 for c in _kb.chunks if c.page_id == p.id)} for p in pages]
			}, indent=2)
		else:
			lines = [f"## {total} pages (showing {len(pages)}, offset {offset})\n"]
			for p in pages:
				cc = sum(1 for c in _kb.chunks if c.page_id == p.id)
				lines.append(f"- **{p.title}** (ID: {p.id}) | Chunks: {cc} | Chars: {len(p.plain_text)}")
			text = "\n".join(lines)
		return [TextContent(type="text", text=text)]
	
	elif name == "confluence_kb_stats":
		labels: dict[str, int] = {}
		for p in _kb.pages.values():
			for l in p.labels:
				labels[l] = labels.get(l, 0) + 1
		text = json.dumps({
			"source_url": _kb.source_url, "root_page_ids": _kb.root_page_id,
			"generated_at": _kb.generated_at.isoformat(),
			"total_pages": _kb.total_pages, "total_chunks": _kb.total_chunks,
			"estimated_tokens": _kb.estimated_tokens,
			"labels": dict(sorted(labels.items(), key=lambda x: x[1], reverse=True)),
		}, indent=2, default=str)
		return [TextContent(type="text", text=text)]
	
	raise ValueError(f"Unknown tool: {name}")


# ── SSE Transport Setup ──────────────────────────────────────────────────────

transport = SseServerTransport("/messages")


# ── FastAPI App ──────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
	global _kb
	logger.info(f"Loading knowledge base from {KB_PATH}")
	_kb = _load_kb()
	logger.info(f"Loaded: {_kb.total_pages} pages, {_kb.total_chunks} chunks, ~{_kb.estimated_tokens} tokens")
	yield


app = FastAPI(lifespan=lifespan)


@app.get("/health")
async def health():
	return PlainTextResponse("healthy")


@app.get("/sse")
async def handle_sse(request: Request):
	async with transport.connect_sse(
		request.scope,
		request.receive,
		request._send
	) as (read_stream, write_stream):
		await mcp_server.run(
			read_stream,
			write_stream,
			mcp_server.create_initialization_options()
		)


# ── Entrypoint ───────────────────────────────────────────────────────────────

def main() -> None:
	import uvicorn
	logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(name)s] %(levelname)s: %(message)s", stream=sys.stderr)
	uvicorn.run(app, host="0.0.0.0", port=8000)


if __name__ == "__main__":
	main()