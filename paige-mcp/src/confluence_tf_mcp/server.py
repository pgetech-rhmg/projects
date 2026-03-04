#!/usr/bin/env python3
"""Confluence-to-Terraform MCP Server."""

from __future__ import annotations

import json
import logging
import os
import sys
from contextlib import asynccontextmanager
from enum import Enum
from pathlib import Path
from typing import Optional

from fastapi import FastAPI
from fastapi.responses import PlainTextResponse
from starlette.routing import Mount
from mcp.server.fastmcp import FastMCP

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


def _fmt_md(chunks: list[ContentChunk]) -> str:
	return "\n\n".join(c.content for c in chunks) if chunks else "No results found."


def _fmt_json(chunks: list[ContentChunk]) -> str:
	return json.dumps([c.model_dump(exclude={"labels"}) for c in chunks], indent=2, default=str)


# ── MCP Server Setup ─────────────────────────────────────────────────────────

mcp = FastMCP("confluence_tf_mcp")


@mcp.tool()
def confluence_search(query: str, labels: list[str] | None = None, limit: int = 10, response_format: str = "markdown") -> str:
	"""Search the knowledge base for CloudFormation/Terraform content."""
	results = _search_chunks(_kb.chunks, query, labels, limit)
	if not results:
		return f"No results for '{query}'."
	elif response_format == "json":
		return _fmt_json(results)
	else:
		return f"## Search: '{query}' ({len(results)} results)\n\n" + _fmt_md(results)


@mcp.tool()
def confluence_get_page(page_id: str, response_format: str = "markdown") -> str:
	"""Get the full content of a specific page by ID."""
	chunks = sorted([c for c in _kb.chunks if c.page_id == page_id], key=lambda c: c.chunk_index)
	if not chunks:
		return f"Page '{_kb.pages[page_id].title}' has no content." if page_id in _kb.pages else f"Page '{page_id}' not found."
	elif response_format == "json":
		return _fmt_json(chunks)
	else:
		return _fmt_md(chunks)


@mcp.tool()
def confluence_list_pages(labels: list[str] | None = None, limit: int = 50, offset: int = 0, response_format: str = "markdown") -> str:
	"""List pages in the knowledge base."""
	pages = list(_kb.pages.values())
	if labels:
		ls = {l.lower() for l in labels}
		pages = [p for p in pages if any(l.lower() in ls for l in p.labels)]
	total = len(pages)
	pages = pages[offset:offset + limit]
	
	if response_format == "json":
		return json.dumps({
			"total": total, "count": len(pages), "offset": offset,
			"pages": [{"id": p.id, "title": p.title, "url": p.url, "chunks": sum(1 for c in _kb.chunks if c.page_id == p.id)} for p in pages]
		}, indent=2)
	else:
		lines = [f"## {total} pages (showing {len(pages)}, offset {offset})\n"]
		for p in pages:
			cc = sum(1 for c in _kb.chunks if c.page_id == p.id)
			lines.append(f"- **{p.title}** (ID: {p.id}) | Chunks: {cc} | Chars: {len(p.plain_text)}")
		return "\n".join(lines)


@mcp.tool()
def confluence_kb_stats() -> str:
	"""Get knowledge base statistics."""
	labels: dict[str, int] = {}
	for p in _kb.pages.values():
		for l in p.labels:
			labels[l] = labels.get(l, 0) + 1
	return json.dumps({
		"source_url": _kb.source_url, "root_page_ids": _kb.root_page_id,
		"generated_at": _kb.generated_at.isoformat(),
		"total_pages": _kb.total_pages, "total_chunks": _kb.total_chunks,
		"estimated_tokens": _kb.estimated_tokens,
		"labels": dict(sorted(labels.items(), key=lambda x: x[1], reverse=True)),
	}, indent=2, default=str)


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

# Mount MCP SSE server
app.mount("/", mcp.sse_app())

# ── Entrypoint ───────────────────────────────────────────────────────────────

def main() -> None:
	import uvicorn
	logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(name)s] %(levelname)s: %(message)s", stream=sys.stderr)
	uvicorn.run(app, host="0.0.0.0", port=8000)


if __name__ == "__main__":
	main()