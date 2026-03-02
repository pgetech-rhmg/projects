#!/usr/bin/env python3
"""CLI for crawling Confluence and building the knowledge base.

Run this standalone to pre-build the knowledge base before starting the MCP server.
This way the server starts instantly with cached data.

Usage:
	python -m confluence_tf_mcp.cli crawl --root-page-id 12345678
	python -m confluence_tf_mcp.cli stats
	python -m confluence_tf_mcp.cli search "VPC networking"
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
import sys
from pathlib import Path

from .config import get_config
from .knowledge_base import build_knowledge_base, load_knowledge_base, DEFAULT_KB_PATH


async def cmd_crawl(args: argparse.Namespace) -> None:
	config = get_config()
	base_url = args.base_url or config["confluence_base_url"]
	pat_token = args.pat_token or config["confluence_pat_token"]
	root_page_id = args.root_page_id or config["confluence_root_page_id"]

	if not pat_token:
		print("Error: No PAT token found. Set CONFLUENCE_PAT_TOKEN in .env or pass --pat-token.", file=sys.stderr)
		sys.exit(1)
	if not root_page_id:
		print("Error: No root page ID found. Set CONFLUENCE_ROOT_PAGE_ID in .env or pass --root-page-id.", file=sys.stderr)
		sys.exit(1)
	output = Path(args.output)

	kb = await build_knowledge_base(
		base_url=base_url,
		pat_token=pat_token,
		root_page_id=root_page_id,
		max_chunk_tokens=args.max_chunk_tokens,
		overlap_tokens=args.overlap_tokens,
		output_path=output,
	)

	print(f"\nDone: {kb.total_pages} pages, {kb.total_chunks} chunks, ~{kb.estimated_tokens} tokens")
	print(f"Saved to: {output}")


def cmd_stats(args: argparse.Namespace) -> None:
	path = Path(args.kb_path)
	if not path.exists():
		print(f"Error: {path} not found. Run 'crawl' first.", file=sys.stderr)
		sys.exit(1)

	kb = load_knowledge_base(path)

	label_counts: dict[str, int] = {}
	for page in kb.pages.values():
		for label in page.labels:
			label_counts[label] = label_counts.get(label, 0) + 1

	print(f"Knowledge Base: {path}")
	print(f"  Generated:  {kb.generated_at.isoformat()}")
	print(f"  Source:     {kb.source_url}")
	print(f"  Root Page:  {kb.root_page_id}")
	print(f"  Pages:      {kb.total_pages}")
	print(f"  Chunks:     {kb.total_chunks}")
	print(f"  Est Tokens: {kb.estimated_tokens}")
	if label_counts:
		print(f"  Labels:")
		for label, count in sorted(label_counts.items(), key=lambda x: x[1], reverse=True):
			print(f"    {label}: {count}")


def cmd_search(args: argparse.Namespace) -> None:
	path = Path(args.kb_path)
	if not path.exists():
		print(f"Error: {path} not found. Run 'crawl' first.", file=sys.stderr)
		sys.exit(1)

	kb = load_knowledge_base(path)

	query_terms = args.query.lower().split()
	scored: list[tuple[float, int]] = []

	for i, chunk in enumerate(kb.chunks):
		content_lower = chunk.content.lower()
		title_lower = chunk.page_title.lower()
		score = 0.0
		for term in query_terms:
			if term in title_lower:
				score += 3.0
			score += content_lower.count(term)
		if score > 0:
			scored.append((score, i))

	scored.sort(key=lambda x: x[0], reverse=True)

	limit = args.limit
	print(f"Search: '{args.query}' ({min(len(scored), limit)} of {len(scored)} results)\n")

	for score, idx in scored[:limit]:
		chunk = kb.chunks[idx]
		print(f"--- [{chunk.page_title}] (score: {score:.1f}, page: {chunk.page_id}) ---")
		# Show first 500 chars of content
		preview = chunk.content[:500].replace("\n", " ")
		print(f"{preview}...")
		print()


def main() -> None:
	logging.basicConfig(
		level=logging.INFO,
		format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
		stream=sys.stderr,
	)

	parser = argparse.ArgumentParser(description="Confluence-to-Terraform Knowledge Base CLI")
	sub = parser.add_subparsers(dest="command", required=True)

	# crawl
	crawl_p = sub.add_parser("crawl", help="Crawl Confluence and build knowledge base")
	crawl_p.add_argument("--root-page-id", default="", help="Root page ID (or set CONFLUENCE_ROOT_PAGE_ID)")
	crawl_p.add_argument("--base-url", default="", help="Confluence base URL")
	crawl_p.add_argument("--pat-token", default="", help="PAT token (or set CONFLUENCE_PAT_TOKEN)")
	crawl_p.add_argument("--output", default=str(DEFAULT_KB_PATH), help="Output path")
	crawl_p.add_argument("--max-chunk-tokens", type=int, default=1500)
	crawl_p.add_argument("--overlap-tokens", type=int, default=150)

	# stats
	stats_p = sub.add_parser("stats", help="Show knowledge base statistics")
	stats_p.add_argument("--kb-path", default=str(DEFAULT_KB_PATH))

	# search
	search_p = sub.add_parser("search", help="Search the knowledge base")
	search_p.add_argument("query", help="Search query")
	search_p.add_argument("--kb-path", default=str(DEFAULT_KB_PATH))
	search_p.add_argument("--limit", type=int, default=5)

	args = parser.parse_args()

	if args.command == "crawl":
		asyncio.run(cmd_crawl(args))
	elif args.command == "stats":
		cmd_stats(args)
	elif args.command == "search":
		cmd_search(args)


if __name__ == "__main__":
	main()