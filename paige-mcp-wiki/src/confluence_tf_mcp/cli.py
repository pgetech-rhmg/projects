"""CLI for crawling Confluence."""
from __future__ import annotations
import argparse, asyncio, logging, sys
from pathlib import Path
from .config import get_config, parse_verify_ssl, parse_page_ids, build_auth_cookies
from .knowledge_base import build_knowledge_base, load_knowledge_base, DEFAULT_KB_PATH


async def cmd_crawl(args):
	config = get_config()
	base_url = args.base_url or config["confluence_base_url"]
	pat_token = args.pat_token or config["confluence_pat_token"]
	verify_ssl = parse_verify_ssl(config["verify_ssl"])
	auth_cookies = build_auth_cookies(config)

	# Merge CLI page IDs with config page IDs
	page_ids = []
	if args.root_page_ids:
		page_ids = parse_page_ids(args.root_page_ids)
	else:
		page_ids = parse_page_ids(config["confluence_root_page_ids"])

	if not pat_token and not auth_cookies:
		print("Error: No auth. Set PAT token or session cookies in .env.", file=sys.stderr)
		sys.exit(1)
	if not page_ids:
		print("Error: No page IDs. Set CONFLUENCE_ROOT_PAGE_IDS in .env.", file=sys.stderr)
		sys.exit(1)

	print(f"Crawling {len(page_ids)} root page(s): {', '.join(page_ids)}")
	kb = await build_knowledge_base(
		base_url=base_url, root_page_ids=page_ids,
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
	print(f"Root pages: {kb.root_page_id}")
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


def cmd_serve(args):
	from .server import main as server_main
	server_main()


def main():
	logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s: %(message)s", stream=sys.stderr)
	p = argparse.ArgumentParser()
	sub = p.add_subparsers(dest="command", required=True)
	c = sub.add_parser("crawl")
	c.add_argument("--root-page-ids", default="", help="Comma-separated page IDs")
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
	srv = sub.add_parser("serve")
	args = p.parse_args()
	if args.command == "crawl": asyncio.run(cmd_crawl(args))
	elif args.command == "stats": cmd_stats(args)
	elif args.command == "search": cmd_search(args)
	elif args.command == "serve": cmd_serve(args)