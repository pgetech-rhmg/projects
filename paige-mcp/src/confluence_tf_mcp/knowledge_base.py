"""KB builder with multi-root merge support."""
from __future__ import annotations
import json, logging
from pathlib import Path
from .chunker import chunk_all_pages
from .crawler import ConfluenceCrawler
from .models import KnowledgeBase

logger = logging.getLogger(__name__)
DEFAULT_KB_PATH = Path("knowledge_base.json")


async def build_knowledge_base(base_url, root_page_ids, pat_token=None, auth_cookies=None, max_chunk_tokens=1500, overlap_tokens=150, output_path=None, verify_ssl=True):
	"""Crawl multiple root pages and merge into one KB."""
	output_path = output_path or DEFAULT_KB_PATH
	crawler = ConfluenceCrawler(base_url, auth_cookies=auth_cookies, pat_token=pat_token, verify_ssl=verify_ssl)

	all_pages = {}
	for pid in root_page_ids:
		logger.info(f"Crawling root page: {pid}")
		pages = await crawler.crawl_from_page(pid)
		all_pages.update(pages)
		logger.info(f"  Got {len(pages)} pages from {pid} ({len(all_pages)} total)")

	if not all_pages:
		logger.warning("No pages crawled.")
		return KnowledgeBase(source_url=base_url, root_page_id=",".join(root_page_ids))

	chunks = chunk_all_pages(all_pages, max_chunk_tokens, overlap_tokens)
	kb = KnowledgeBase(
		source_url=base_url,
		root_page_id=",".join(root_page_ids),
		total_pages=len(all_pages),
		total_chunks=len(chunks),
		estimated_tokens=sum(c.token_estimate for c in chunks),
		pages=all_pages,
		chunks=chunks,
	)
	path = Path(output_path)
	path.parent.mkdir(parents=True, exist_ok=True)
	with open(path, "w") as f:
		f.write(kb.model_dump_json(indent=2))
	logger.info(f"Saved: {kb.total_pages} pages, {kb.total_chunks} chunks, ~{kb.estimated_tokens} tokens")
	return kb


def load_knowledge_base(path):
	with open(path) as f:
		return KnowledgeBase.model_validate(json.load(f))