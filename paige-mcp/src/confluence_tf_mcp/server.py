#!/usr/bin/env python3
"""Confluence-to-Terraform MCP Server.

Provides tools for searching and retrieving CloudFormation/Terraform documentation
from a crawled Confluence knowledge base. Designed to be used as context for
AI-assisted CloudFormation-to-Terraform conversions.
"""

from __future__ import annotations

import asyncio
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

from .chunker import estimate_tokens
from .config import get_config, parse_verify_ssl
from .knowledge_base import build_knowledge_base, load_knowledge_base, DEFAULT_KB_PATH
from .models import ContentChunk, KnowledgeBase

logger = logging.getLogger(__name__)

# ── Config ───────────────────────────────────────────────────────────────────

_config = get_config()
CONFLUENCE_BASE_URL = _config["confluence_base_url"]
CONFLUENCE_PAT_TOKEN = _config["confluence_pat_token"]
CONFLUENCE_ROOT_PAGE_ID = _config["confluence_root_page_id"]
KB_PATH = Path(_config["kb_path"])
VERIFY_SSL = parse_verify_ssl(_config["verify_ssl"])


# ── Lifespan: load knowledge base at startup ─────────────────────────────────

@asynccontextmanager
async def server_lifespan():
	"""Load or build the knowledge base when the server starts."""

	kb: Optional[KnowledgeBase] = None

	if KB_PATH.exists():
		logger.info(f"Loading existing knowledge base from {KB_PATH}")
		kb = load_knowledge_base(KB_PATH)
		logger.info(
			f"Loaded: {kb.total_pages} pages, {kb.total_chunks} chunks, "
			f"~{kb.estimated_tokens} tokens"
		)
	else:
		logger.info("No existing knowledge base found.")
		if CONFLUENCE_PAT_TOKEN and CONFLUENCE_ROOT_PAGE_ID:
			logger.info("Building knowledge base from Confluence...")
			kb = await build_knowledge_base(
				base_url=CONFLUENCE_BASE_URL,
				pat_token=CONFLUENCE_PAT_TOKEN,
				root_page_id=CONFLUENCE_ROOT_PAGE_ID,
				output_path=KB_PATH,
				verify_ssl=VERIFY_SSL,
			)
		else:
			logger.warning(
				"Set CONFLUENCE_PAT_TOKEN and CONFLUENCE_ROOT_PAGE_ID to auto-build, "
				"or use the confluence_crawl tool to build manually."
			)

	yield {"kb": kb}


# ── Server init ──────────────────────────────────────────────────────────────

mcp = FastMCP("confluence_tf_mcp", lifespan=server_lifespan)


# ── Shared helpers ───────────────────────────────────────────────────────────

def _get_kb(ctx: Context) -> Optional[KnowledgeBase]:
	"""Get the knowledge base from lifespan state."""
	return ctx.request_context.lifespan_state.get("kb")


def _set_kb(ctx: Context, kb: KnowledgeBase) -> None:
	"""Update the knowledge base in lifespan state."""
	ctx.request_context.lifespan_state["kb"] = kb


def _search_chunks(
	chunks: list[ContentChunk],
	query: str,
	labels: Optional[list[str]] = None,
	limit: int = 10,
) -> list[ContentChunk]:
	"""Simple keyword search across chunks. Returns ranked results."""

	query_terms = query.lower().split()
	scored: list[tuple[float, ContentChunk]] = []

	for chunk in chunks:
		content_lower = chunk.content.lower()
		title_lower = chunk.page_title.lower()

		# Score: title matches weighted 3x, content matches 1x
		score = 0.0
		for term in query_terms:
			if term in title_lower:
				score += 3.0
			score += content_lower.count(term) * 1.0

		# Label filter
		if labels:
			chunk_labels_lower = {l.lower() for l in chunk.labels}
			if not any(l.lower() in chunk_labels_lower for l in labels):
				continue

		if score > 0:
			scored.append((score, chunk))

	scored.sort(key=lambda x: x[0], reverse=True)
	return [chunk for _, chunk in scored[:limit]]


def _format_chunks_markdown(chunks: list[ContentChunk]) -> str:
	"""Format chunks as markdown for LLM consumption."""
	if not chunks:
		return "No results found."

	parts: list[str] = []
	for chunk in chunks:
		parts.append(chunk.content)
		parts.append("")  # blank line separator

	return "\n".join(parts)


def _format_chunks_json(chunks: list[ContentChunk]) -> str:
	"""Format chunks as JSON."""
	return json.dumps(
		[chunk.model_dump(exclude={"labels"}) for chunk in chunks],
		indent=2,
		default=str,
	)


# ── Enums and Input Models ───────────────────────────────────────────────────

class ResponseFormat(str, Enum):
	"""Output format for tool responses."""
	MARKDOWN = "markdown"
	JSON = "json"


class SearchInput(BaseModel):
	"""Input for searching the knowledge base."""

	model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")

	query: str = Field(
		...,
		description=(
			"Search query -- use CloudFormation resource types (e.g. 'AWS::EC2::Instance'), "
			"Terraform resource names (e.g. 'aws_instance'), or descriptive terms "
			"(e.g. 'VPC networking', 'IAM roles', 'S3 bucket policy')"
		),
		min_length=2,
		max_length=500,
	)
	labels: Optional[list[str]] = Field(
		default=None,
		description="Filter by Confluence page labels (e.g. ['cloudformation', 'networking'])",
	)
	limit: int = Field(
		default=10,
		description="Maximum number of chunks to return",
		ge=1,
		le=50,
	)
	response_format: ResponseFormat = Field(
		default=ResponseFormat.MARKDOWN,
		description="Output format: 'markdown' for LLM context or 'json' for structured data",
	)

	@field_validator("query")
	@classmethod
	def validate_query(cls, v: str) -> str:
		if not v.strip():
			raise ValueError("Query cannot be empty")
		return v.strip()


class GetPageInput(BaseModel):
	"""Input for retrieving a specific page."""

	model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")

	page_id: str = Field(
		...,
		description="Confluence page ID to retrieve",
		min_length=1,
	)
	response_format: ResponseFormat = Field(
		default=ResponseFormat.MARKDOWN,
		description="Output format",
	)


class ListPagesInput(BaseModel):
	"""Input for listing pages in the knowledge base."""

	model_config = ConfigDict(extra="forbid")

	labels: Optional[list[str]] = Field(
		default=None,
		description="Filter by labels",
	)
	limit: int = Field(default=50, ge=1, le=200)
	offset: int = Field(default=0, ge=0)
	response_format: ResponseFormat = Field(default=ResponseFormat.MARKDOWN)


class CrawlInput(BaseModel):
	"""Input for triggering a fresh crawl."""

	model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")

	root_page_id: str = Field(
		...,
		description="Confluence page ID to start crawling from",
		min_length=1,
	)
	base_url: str = Field(
		default=CONFLUENCE_BASE_URL,
		description="Confluence base URL",
	)
	pat_token: str = Field(
		default="",
		description="PAT token (uses env var CONFLUENCE_PAT_TOKEN if empty)",
	)
	max_chunk_tokens: int = Field(
		default=1500,
		description="Max tokens per content chunk",
		ge=500,
		le=8000,
	)


# ── Tools ────────────────────────────────────────────────────────────────────

@mcp.tool(
	name="confluence_search",
	annotations={
		"title": "Search Confluence Knowledge Base",
		"readOnlyHint": True,
		"destructiveHint": False,
		"idempotentHint": True,
		"openWorldHint": False,
	},
)
async def confluence_search(params: SearchInput, ctx: Context) -> str:
	"""Search the crawled Confluence knowledge base for CloudFormation and Terraform content.

	Use this tool to find documentation about specific AWS resources, CloudFormation
	templates, Terraform configurations, or infrastructure patterns. Results are
	returned as context-rich chunks suitable for AI-assisted CF-to-TF conversion.

	Args:
		params (SearchInput): Search parameters containing:
			- query (str): Keywords to search for (CF resource types, TF resources, or descriptions)
			- labels (Optional[list[str]]): Filter by Confluence page labels
			- limit (int): Max results to return (default 10)
			- response_format (ResponseFormat): 'markdown' or 'json'

	Returns:
		str: Matching content chunks formatted for LLM consumption, including page
		metadata (title, URL, labels) prepended to each chunk.
	"""

	kb = _get_kb(ctx)
	if kb is None:
		return "Error: Knowledge base not loaded. Use confluence_crawl to build it first."

	results = _search_chunks(kb.chunks, params.query, params.labels, params.limit)

	if not results:
		return f"No results found for '{params.query}'. Try broader terms or check available labels with confluence_list_pages."

	if params.response_format == ResponseFormat.MARKDOWN:
		header = f"## Search: '{params.query}' ({len(results)} results)\n\n"
		return header + _format_chunks_markdown(results)
	else:
		return _format_chunks_json(results)


@mcp.tool(
	name="confluence_get_page",
	annotations={
		"title": "Get Confluence Page Content",
		"readOnlyHint": True,
		"destructiveHint": False,
		"idempotentHint": True,
		"openWorldHint": False,
	},
)
async def confluence_get_page(params: GetPageInput, ctx: Context) -> str:
	"""Retrieve the full content of a specific Confluence page by its ID.

	Use this when you know the exact page ID and need its complete content,
	including all chunks. Useful after finding a page via confluence_search.

	Args:
		params (GetPageInput): Input containing:
			- page_id (str): The Confluence page ID
			- response_format (ResponseFormat): Output format

	Returns:
		str: Full page content with metadata, concatenated from all chunks.
	"""

	kb = _get_kb(ctx)
	if kb is None:
		return "Error: Knowledge base not loaded."

	# Find all chunks for this page
	page_chunks = [c for c in kb.chunks if c.page_id == params.page_id]

	if not page_chunks:
		# Check if the page exists but has no chunks
		if params.page_id in kb.pages:
			page = kb.pages[params.page_id]
			return f"Page '{page.title}' exists but has no content."
		return f"Error: Page ID '{params.page_id}' not found in knowledge base."

	page_chunks.sort(key=lambda c: c.chunk_index)

	if params.response_format == ResponseFormat.MARKDOWN:
		return _format_chunks_markdown(page_chunks)
	else:
		return _format_chunks_json(page_chunks)


@mcp.tool(
	name="confluence_list_pages",
	annotations={
		"title": "List Knowledge Base Pages",
		"readOnlyHint": True,
		"destructiveHint": False,
		"idempotentHint": True,
		"openWorldHint": False,
	},
)
async def confluence_list_pages(params: ListPagesInput, ctx: Context) -> str:
	"""List all pages in the knowledge base with their metadata.

	Use this to discover available content, find page IDs, or browse by label.
	Returns a summary of each page including title, ID, labels, and chunk count.

	Args:
		params (ListPagesInput): Input containing:
			- labels (Optional[list[str]]): Filter by labels
			- limit (int): Max pages to return
			- offset (int): Pagination offset
			- response_format (ResponseFormat): Output format

	Returns:
		str: List of pages with metadata including ID, title, labels, and content size.
	"""

	kb = _get_kb(ctx)
	if kb is None:
		return "Error: Knowledge base not loaded."

	pages = list(kb.pages.values())

	# Label filter
	if params.labels:
		label_set = {l.lower() for l in params.labels}
		pages = [p for p in pages if any(l.lower() in label_set for l in p.labels)]

	total = len(pages)
	pages = pages[params.offset : params.offset + params.limit]

	if params.response_format == ResponseFormat.MARKDOWN:
		lines = [
			f"## Knowledge Base: {total} pages",
			f"Showing {len(pages)} (offset {params.offset})\n",
		]
		for page in pages:
			chunk_count = sum(1 for c in kb.chunks if c.page_id == page.id)
			labels = ", ".join(page.labels) if page.labels else "none"
			lines.append(f"- **{page.title}** (ID: {page.id})")
			lines.append(f"  Labels: {labels} | Chunks: {chunk_count} | Chars: {len(page.plain_text)}")
		return "\n".join(lines)
	else:
		result = {
			"total": total,
			"count": len(pages),
			"offset": params.offset,
			"pages": [
				{
					"id": p.id,
					"title": p.title,
					"labels": p.labels,
					"url": p.url,
					"content_length": len(p.plain_text),
					"chunk_count": sum(1 for c in kb.chunks if c.page_id == p.id),
				}
				for p in pages
			],
		}
		return json.dumps(result, indent=2)


@mcp.tool(
	name="confluence_kb_stats",
	annotations={
		"title": "Knowledge Base Statistics",
		"readOnlyHint": True,
		"destructiveHint": False,
		"idempotentHint": True,
		"openWorldHint": False,
	},
)
async def confluence_kb_stats(ctx: Context) -> str:
	"""Get statistics about the loaded knowledge base.

	Returns page count, chunk count, token estimates, label distribution,
	and other metadata useful for understanding the available content.

	Returns:
		str: JSON-formatted statistics about the knowledge base.
	"""

	kb = _get_kb(ctx)
	if kb is None:
		return "Error: Knowledge base not loaded. Use confluence_crawl to build it first."

	# Label distribution
	label_counts: dict[str, int] = {}
	for page in kb.pages.values():
		for label in page.labels:
			label_counts[label] = label_counts.get(label, 0) + 1

	stats = {
		"source_url": kb.source_url,
		"root_page_id": kb.root_page_id,
		"generated_at": kb.generated_at.isoformat(),
		"total_pages": kb.total_pages,
		"total_chunks": kb.total_chunks,
		"estimated_tokens": kb.estimated_tokens,
		"labels": dict(sorted(label_counts.items(), key=lambda x: x[1], reverse=True)),
		"largest_pages": sorted(
			[
				{"title": p.title, "id": p.id, "chars": len(p.plain_text)}
				for p in kb.pages.values()
			],
			key=lambda x: x["chars"],
			reverse=True,
		)[:10],
	}

	return json.dumps(stats, indent=2, default=str)


@mcp.tool(
	name="confluence_crawl",
	annotations={
		"title": "Crawl Confluence and Build Knowledge Base",
		"readOnlyHint": False,
		"destructiveHint": False,
		"idempotentHint": False,
		"openWorldHint": True,
	},
)
async def confluence_crawl(params: CrawlInput, ctx: Context) -> str:
	"""Crawl Confluence starting from a root page and build/rebuild the knowledge base.

	This fetches all pages under the given root page ID using the Confluence REST API,
	extracts and cleans content, chunks it for LLM consumption, and saves the result.
	The knowledge base is immediately available for searching after crawl completes.

	Args:
		params (CrawlInput): Crawl parameters containing:
			- root_page_id (str): Confluence page ID to start from
			- base_url (str): Confluence base URL (default from env)
			- pat_token (str): PAT token (default from env)
			- max_chunk_tokens (int): Max tokens per chunk (default 1500)

	Returns:
		str: Summary of the crawl results including page count, chunk count, and token estimate.
	"""

	token = params.pat_token or CONFLUENCE_PAT_TOKEN
	if not token:
		return "Error: No PAT token provided. Set CONFLUENCE_PAT_TOKEN env var or pass pat_token."

	await ctx.report_progress(0.1, "Starting Confluence crawl...")

	try:
		kb = await build_knowledge_base(
			base_url=params.base_url,
			pat_token=token,
			root_page_id=params.root_page_id,
			max_chunk_tokens=params.max_chunk_tokens,
			output_path=KB_PATH,
			verify_ssl=VERIFY_SSL,
		)
	except Exception as e:
		return f"Error during crawl: {type(e).__name__}: {e}"

	_set_kb(ctx, kb)

	await ctx.report_progress(1.0, "Crawl complete!")

	return (
		f"Crawl complete!\n"
		f"- Pages: {kb.total_pages}\n"
		f"- Chunks: {kb.total_chunks}\n"
		f"- Estimated tokens: {kb.estimated_tokens}\n"
		f"- Saved to: {KB_PATH}\n"
		f"\nUse confluence_search to query the knowledge base."
	)


# ── Resources ────────────────────────────────────────────────────────────────

@mcp.resource("confluence://pages/{page_id}")
async def get_page_resource(page_id: str) -> str:
	"""Expose individual pages as MCP resources."""

	if not KB_PATH.exists():
		return "Knowledge base not loaded."

	kb = load_knowledge_base(KB_PATH)
	if page_id not in kb.pages:
		return f"Page {page_id} not found."

	page = kb.pages[page_id]
	return f"# {page.title}\n\nURL: {page.url}\nLabels: {', '.join(page.labels)}\n\n{page.plain_text}"


# ── Entrypoint ───────────────────────────────────────────────────────────────

def main() -> None:
	"""Run the MCP server."""

	logging.basicConfig(
		level=logging.INFO,
		format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
		stream=sys.stderr,  # MCP stdio transport requires stderr for logging
	)

	mcp.run()


if __name__ == "__main__":
	main()
