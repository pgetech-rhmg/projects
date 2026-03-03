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

from mcp.server.fastmcp import FastMCP, Context
from pydantic import BaseModel, Field, ConfigDict, field_validator

from .models import ContentChunk, KnowledgeBase

logger = logging.getLogger(__name__)

KB_PATH = Path(os.environ.get("KB_PATH", "./knowledge_base.json"))


def _load_kb() -> KnowledgeBase:
	if not KB_PATH.exists():
		raise FileNotFoundError(f"Knowledge base not found at {KB_PATH}")
	with open(KB_PATH) as f:
		return KnowledgeBase.model_validate(json.load(f))


@asynccontextmanager
async def server_lifespan(app):  # ← Add 'app' parameter
	logger.info(f"Loading knowledge base from {KB_PATH}")
	kb = _load_kb()
	logger.info(f"Loaded: {kb.total_pages} pages, {kb.total_chunks} chunks, ~{kb.estimated_tokens} tokens")
	yield {"kb": kb}


mcp = FastMCP("confluence_tf_mcp", lifespan=server_lifespan)


# ── Helpers ──────────────────────────────────────────────────────────────────

def _get_kb(ctx: Context) -> KnowledgeBase:
	return ctx.request_context.lifespan_state["kb"]


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


class SearchInput(BaseModel):
	model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")
	query: str = Field(..., description="Search terms: CF resource types, TF resources, or keywords", min_length=2, max_length=500)
	labels: Optional[list[str]] = Field(default=None, description="Filter by page labels")
	limit: int = Field(default=10, ge=1, le=50)
	response_format: ResponseFormat = Field(default=ResponseFormat.MARKDOWN)


class GetPageInput(BaseModel):
	model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")
	page_id: str = Field(..., description="Confluence page ID", min_length=1)
	response_format: ResponseFormat = Field(default=ResponseFormat.MARKDOWN)


class ListPagesInput(BaseModel):
	model_config = ConfigDict(extra="forbid")
	labels: Optional[list[str]] = Field(default=None, description="Filter by labels")
	limit: int = Field(default=50, ge=1, le=200)
	offset: int = Field(default=0, ge=0)
	response_format: ResponseFormat = Field(default=ResponseFormat.MARKDOWN)


# ── Formatters ───────────────────────────────────────────────────────────────

def _fmt_md(chunks: list[ContentChunk]) -> str:
	return "\n\n".join(c.content for c in chunks) if chunks else "No results found."


def _fmt_json(chunks: list[ContentChunk]) -> str:
	return json.dumps([c.model_dump(exclude={"labels"}) for c in chunks], indent=2, default=str)


# ── Tools ────────────────────────────────────────────────────────────────────

@mcp.tool(name="confluence_search", annotations={"title": "Search Knowledge Base", "readOnlyHint": True, "destructiveHint": False, "idempotentHint": True, "openWorldHint": False})
async def confluence_search(params: SearchInput, ctx: Context) -> str:
	"""Search the knowledge base for CloudFormation/Terraform content."""
	kb = _get_kb(ctx)
	results = _search_chunks(kb.chunks, params.query, params.labels, params.limit)
	if not results:
		return f"No results for '{params.query}'."
	if params.response_format == ResponseFormat.MARKDOWN:
		return f"## Search: '{params.query}' ({len(results)} results)\n\n" + _fmt_md(results)
	return _fmt_json(results)


@mcp.tool(name="confluence_get_page", annotations={"title": "Get Page Content", "readOnlyHint": True, "destructiveHint": False, "idempotentHint": True, "openWorldHint": False})
async def confluence_get_page(params: GetPageInput, ctx: Context) -> str:
	"""Get the full content of a specific page by ID."""
	kb = _get_kb(ctx)
	chunks = sorted([c for c in kb.chunks if c.page_id == params.page_id], key=lambda c: c.chunk_index)
	if not chunks:
		if params.page_id in kb.pages:
			return f"Page '{kb.pages[params.page_id].title}' has no content."
		return f"Page '{params.page_id}' not found."
	if params.response_format == ResponseFormat.MARKDOWN:
		return _fmt_md(chunks)
	return _fmt_json(chunks)


@mcp.tool(name="confluence_list_pages", annotations={"title": "List Pages", "readOnlyHint": True, "destructiveHint": False, "idempotentHint": True, "openWorldHint": False})
async def confluence_list_pages(params: ListPagesInput, ctx: Context) -> str:
	"""List pages in the knowledge base."""
	kb = _get_kb(ctx)
	pages = list(kb.pages.values())
	if params.labels:
		ls = {l.lower() for l in params.labels}
		pages = [p for p in pages if any(l.lower() in ls for l in p.labels)]
	total = len(pages)
	pages = pages[params.offset:params.offset + params.limit]
	if params.response_format == ResponseFormat.MARKDOWN:
		lines = [f"## {total} pages (showing {len(pages)}, offset {params.offset})\n"]
		for p in pages:
			cc = sum(1 for c in kb.chunks if c.page_id == p.id)
			lines.append(f"- **{p.title}** (ID: {p.id}) | Chunks: {cc} | Chars: {len(p.plain_text)}")
		return "\n".join(lines)
	return json.dumps({"total": total, "count": len(pages), "offset": params.offset, "pages": [{"id": p.id, "title": p.title, "url": p.url, "chunks": sum(1 for c in kb.chunks if c.page_id == p.id)} for p in pages]}, indent=2)


@mcp.tool(name="confluence_kb_stats", annotations={"title": "KB Statistics", "readOnlyHint": True, "destructiveHint": False, "idempotentHint": True, "openWorldHint": False})
async def confluence_kb_stats(ctx: Context) -> str:
	"""Get knowledge base statistics."""
	kb = _get_kb(ctx)
	labels: dict[str, int] = {}
	for p in kb.pages.values():
		for l in p.labels:
			labels[l] = labels.get(l, 0) + 1
	return json.dumps({
		"source_url": kb.source_url, "root_page_ids": kb.root_page_id,
		"generated_at": kb.generated_at.isoformat(),
		"total_pages": kb.total_pages, "total_chunks": kb.total_chunks,
		"estimated_tokens": kb.estimated_tokens,
		"labels": dict(sorted(labels.items(), key=lambda x: x[1], reverse=True)),
	}, indent=2, default=str)


# ── Resources ────────────────────────────────────────────────────────────────

@mcp.resource("confluence://pages/{page_id}")
async def get_page_resource(page_id: str) -> str:
	kb = _load_kb()
	if page_id not in kb.pages:
		return f"Page {page_id} not found."
	p = kb.pages[page_id]
	return f"# {p.title}\n\nURL: {p.url}\n\n{p.plain_text}"


# ── Entrypoint ───────────────────────────────────────────────────────────────

def main() -> None:
	logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(name)s] %(levelname)s: %(message)s", stream=sys.stderr)
	mcp.run(transport="sse")

if __name__ == "__main__":
	main()