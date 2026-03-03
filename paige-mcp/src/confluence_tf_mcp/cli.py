"""CLI for crawling Confluence."""
from __future__ import annotations
import argparse, asyncio, logging, sys
from pathlib import Path
from .config import get_config, parse_verify_ssl, build_auth_cookies
from .knowledge_base import build_knowledge_base, load_knowledge_base, DEFAULT_KB_PATH

async def cmd_crawl(args):
	config = get_config()
	base_url = args.base_url or config["confluence_base_url"]
	pat_token = args.pat_token or config["confluence_pat_token"]
	root_page_id = args.root_page_id or config["confluence_root_page_id"]
	verify_ssl = parse_verify_ssl(config["verify_ssl"])
	auth_cookies = build_auth_cookies(config)
	if not pat_token and not auth_cookies:
		print("Error: No auth. Set PAT token or session cookies in .env.", file=sys.stderr)
		sys.exit(1)
	if not root_page_id:
		print("Error: No root page ID. Set CONFLUENCE_ROOT_PAGE_ID in .env.", file=sys.stderr)
		sys.exit(1)
	kb = await build_knowledge_base(
		base_url=base_url, root_page_id=root_page_id,
		pat_token=pat_token if pat_token else None,
		auth_cookies=auth_cookies,
		max_chunk_tokens=args.max_chunk_tokens,
		overlap_tokens=args.overlap_tokens,
		output_path=Path(args.output), verify_ssl=verify_ssl)
	print(f"\nDone: {kb.total_pages} pages, {kb.total_chunks} chunks, ~{kb.estimated_tokens} tokens")

def cmd_stats(args):
	path = Path(args.kb_path)
	if not path.exists():
		print(f"Error: {path} not found.", file=sys.stderr); sys.exit(1)
	kb = load_knowledge_base(path)
	print(f"Pages: {kb.total_pages}  Chunks: {kb.total_chunks}  Tokens: {kb.estimated_tokens}")

def cmd_search(args):
	path = Path(args.kb_path)
	if not path.exists():
		print(f"Error: {path} not found.", file=sys.stderr); sys.exit(1)
	kb = load_knowledge_base(path)
	terms = args.query.lower().split()
	scored = []
	for i, ch in enumerate(kb.chunks):
		s = sum(3.0 if t in ch.page_title.lower() else 0 for t in terms) + sum(ch.content.lower().count(t) for t in terms)
		if s > 0: scored.append((s, i))
	scored.sort(key=lambda x: x[0], reverse=True)
	for sc, idx in scored[:args.limit]:
		ch = kb.chunks[idx]
		print(f"--- [{ch.page_title}] score={sc:.1f} ---")
		print(ch.content[:500] + "...\n")

def main():
	logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s: %(message)s", stream=sys.stderr)
	p = argparse.ArgumentParser()
	sub = p.add_subparsers(dest="command", required=True)
	c = sub.add_parser("crawl")
	c.add_argument("--root-page-id", default="")
	c.add_argument("--base-url", default="")
	c.add_argument("--pat-token", default="")
	c.add_argument("--output", default=str(DEFAULT_KB_PATH))
	c.add_argument("--max-chunk-tokens", type=int, default=1500)
	c.add_argument("--overlap-tokens", type=int, default=150)
	s = sub.add_parser("stats")
	s.add_argument("--kb-path", default=str(DEFAULT_KB_PATH))
	q = sub.add_parser("search")
	q.add_argument("query")
	q.add_argument("--kb-path", default=str(DEFAULT_KB_PATH))
	q.add_argument("--limit", type=int, default=5)
	args = p.parse_args()
	if args.command == "crawl": asyncio.run(cmd_crawl(args))
	elif args.command == "stats": cmd_stats(args)
	elif args.command == "search": cmd_search(args)