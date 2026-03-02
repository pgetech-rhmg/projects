"""Knowledge base builder and persistence.

Orchestrates crawling, chunking, and export into a single JSON knowledge base
file that can be loaded by the MCP server at startup.
"""

from __future__ import annotations

import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional

from .chunker import chunk_all_pages, estimate_tokens
from .crawler import ConfluenceCrawler
from .models import ContentChunk, ConfluencePage, KnowledgeBase

logger = logging.getLogger(__name__)

DEFAULT_KB_PATH = Path("knowledge_base.json")


async def build_knowledge_base(
	base_url: str,
	pat_token: str,
	root_page_id: str,
	max_chunk_tokens: int = 1500,
	overlap_tokens: int = 150,
	output_path: Optional[Path] = None,
) -> KnowledgeBase:
	"""Crawl Confluence and build the full knowledge base.

	Args:
		base_url: Confluence base URL (e.g. https://wiki.comp.pge.com)
		pat_token: Personal Access Token for auth
		root_page_id: Root page ID to start crawling from
		max_chunk_tokens: Max tokens per chunk
		overlap_tokens: Token overlap between adjacent chunks
		output_path: Where to save the JSON KB file

	Returns:
		The built KnowledgeBase
	"""

	output_path = output_path or DEFAULT_KB_PATH

	# Crawl
	logger.info(f"Starting crawl from page {root_page_id} at {base_url}")
	crawler = ConfluenceCrawler(base_url, pat_token)
	pages = await crawler.crawl_from_page(root_page_id)

	if not pages:
		logger.warning("No pages were crawled. Check your root_page_id and auth token.")
		return KnowledgeBase(
			source_url=base_url,
			root_page_id=root_page_id,
		)

	# Chunk
	logger.info(f"Chunking {len(pages)} pages...")
	chunks = chunk_all_pages(pages, max_chunk_tokens, overlap_tokens)

	total_tokens = sum(c.token_estimate for c in chunks)

	kb = KnowledgeBase(
		source_url=base_url,
		root_page_id=root_page_id,
		total_pages=len(pages),
		total_chunks=len(chunks),
		estimated_tokens=total_tokens,
		pages=pages,
		chunks=chunks,
	)

	# Save
	save_knowledge_base(kb, output_path)
	logger.info(
		f"Knowledge base saved to {output_path}: "
		f"{kb.total_pages} pages, {kb.total_chunks} chunks, ~{kb.estimated_tokens} tokens"
	)

	return kb


def save_knowledge_base(kb: KnowledgeBase, path: Path) -> None:
	"""Serialize and save the knowledge base to JSON."""
	path.parent.mkdir(parents=True, exist_ok=True)
	with open(path, "w", encoding="utf-8") as f:
		f.write(kb.model_dump_json(indent=2))


def load_knowledge_base(path: Path) -> KnowledgeBase:
	"""Load a previously saved knowledge base from JSON."""
	with open(path, "r", encoding="utf-8") as f:
		data = json.load(f)
	return KnowledgeBase.model_validate(data)
