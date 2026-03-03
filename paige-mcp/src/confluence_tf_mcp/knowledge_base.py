"""KB builder."""
from __future__ import annotations
import json
from pathlib import Path
from .chunker import chunk_all_pages
from .crawler import ConfluenceCrawler
from .models import KnowledgeBase

DEFAULT_KB_PATH = Path("knowledge_base.json")

async def build_knowledge_base(base_url, root_page_id, pat_token=None, auth_cookies=None, max_chunk_tokens=1500, overlap_tokens=150, output_path=None, verify_ssl=True):
	output_path = output_path or DEFAULT_KB_PATH
	cr = ConfluenceCrawler(base_url, auth_cookies=auth_cookies, pat_token=pat_token, verify_ssl=verify_ssl)
	pages = await cr.crawl_from_page(root_page_id)
	if not pages:
		return KnowledgeBase(source_url=base_url, root_page_id=root_page_id)
	chunks = chunk_all_pages(pages, max_chunk_tokens, overlap_tokens)
	kb = KnowledgeBase(source_url=base_url, root_page_id=root_page_id, total_pages=len(pages), total_chunks=len(chunks), estimated_tokens=sum(c.token_estimate for c in chunks), pages=pages, chunks=chunks)
	path = Path(output_path)
	path.parent.mkdir(parents=True, exist_ok=True)
	with open(path, "w") as f:
		f.write(kb.model_dump_json(indent=2))
	return kb

def load_knowledge_base(path):
	with open(path) as f:
		return KnowledgeBase.model_validate(json.load(f))