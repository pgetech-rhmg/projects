"""Content chunker optimized for LLM context windows.

Splits crawled pages into token-sized chunks with overlap for continuity.
Uses a simple word-based token estimate (~0.75 tokens per word for English).
"""

from __future__ import annotations

import hashlib
import logging
import re

from .models import ConfluencePage, ContentChunk

logger = logging.getLogger(__name__)

# Conservative estimate: ~1.3 words per token for English text
WORDS_PER_TOKEN = 1.3
DEFAULT_CHUNK_TOKENS = 1500
DEFAULT_OVERLAP_TOKENS = 150


def estimate_tokens(text: str) -> int:
	"""Rough token count estimate from word count."""
	word_count = len(text.split())
	return int(word_count / WORDS_PER_TOKEN)


def chunk_page(
	page: ConfluencePage,
	max_tokens: int = DEFAULT_CHUNK_TOKENS,
	overlap_tokens: int = DEFAULT_OVERLAP_TOKENS,
) -> list[ContentChunk]:
	"""Split a page's content into LLM-friendly chunks.

	Strategy:
	1. Try to split on section boundaries (headings) first
	2. Fall back to paragraph splits
	3. Last resort: hard split on sentences
	"""

	text = page.plain_text
	if not text.strip():
		return []

	# If it fits in one chunk, don't split
	total_tokens = estimate_tokens(text)
	if total_tokens <= max_tokens:
		return [_make_chunk(page, text, 0, 1)]

	sections = _split_on_headings(text)
	raw_chunks: list[str] = []

	for section in sections:
		section_tokens = estimate_tokens(section)
		if section_tokens <= max_tokens:
			raw_chunks.append(section)
		else:
			# Section too big -- split on paragraphs
			raw_chunks.extend(_split_on_paragraphs(section, max_tokens))

	# Merge small chunks to avoid tiny fragments
	merged = _merge_small_chunks(raw_chunks, max_tokens)

	# Add overlap between chunks for context continuity
	overlapped = _add_overlap(merged, overlap_tokens)

	return [
		_make_chunk(page, content, idx, len(overlapped))
		for idx, content in enumerate(overlapped)
	]


def chunk_all_pages(
	pages: dict[str, ConfluencePage],
	max_tokens: int = DEFAULT_CHUNK_TOKENS,
	overlap_tokens: int = DEFAULT_OVERLAP_TOKENS,
) -> list[ContentChunk]:
	"""Chunk all pages and return a flat list."""

	all_chunks: list[ContentChunk] = []
	for page in pages.values():
		chunks = chunk_page(page, max_tokens, overlap_tokens)
		all_chunks.extend(chunks)

	logger.info(
		f"Chunked {len(pages)} pages into {len(all_chunks)} chunks, "
		f"~{sum(c.token_estimate for c in all_chunks)} tokens total"
	)
	return all_chunks


def _split_on_headings(text: str) -> list[str]:
	"""Split text on markdown headings."""
	pattern = re.compile(r"(?=^#{1,6}\s)", re.MULTILINE)
	parts = pattern.split(text)
	return [p.strip() for p in parts if p.strip()]


def _split_on_paragraphs(text: str, max_tokens: int) -> list[str]:
	"""Split text on double newlines (paragraphs), respecting max_tokens."""
	paragraphs = re.split(r"\n\n+", text)
	chunks: list[str] = []
	current: list[str] = []
	current_tokens = 0

	for para in paragraphs:
		para_tokens = estimate_tokens(para)
		if current_tokens + para_tokens > max_tokens and current:
			chunks.append("\n\n".join(current))
			current = [para]
			current_tokens = para_tokens
		else:
			current.append(para)
			current_tokens += para_tokens

	if current:
		chunks.append("\n\n".join(current))

	return chunks


def _merge_small_chunks(chunks: list[str], max_tokens: int) -> list[str]:
	"""Merge adjacent small chunks to avoid fragments under 200 tokens."""
	if not chunks:
		return chunks

	merged: list[str] = []
	current = chunks[0]

	for chunk in chunks[1:]:
		combined_tokens = estimate_tokens(current + "\n\n" + chunk)
		if combined_tokens <= max_tokens:
			current = current + "\n\n" + chunk
		else:
			merged.append(current)
			current = chunk

	merged.append(current)
	return merged


def _add_overlap(chunks: list[str], overlap_tokens: int) -> list[str]:
	"""Add trailing context from the previous chunk to the start of each chunk."""
	if len(chunks) <= 1 or overlap_tokens <= 0:
		return chunks

	result = [chunks[0]]
	overlap_words = int(overlap_tokens * WORDS_PER_TOKEN)

	for i in range(1, len(chunks)):
		prev_words = chunks[i - 1].split()
		overlap_text = " ".join(prev_words[-overlap_words:]) if len(prev_words) > overlap_words else chunks[i - 1]
		result.append(f"[...continued]\n{overlap_text}\n\n{chunks[i]}")

	return result


def _make_chunk(
	page: ConfluencePage,
	content: str,
	index: int,
	total: int,
) -> ContentChunk:
	"""Create a ContentChunk with a header containing page metadata."""

	# Prepend page context to every chunk so the LLM always knows the source
	header = (
		f"--- Page: {page.title} ---\n"
		f"URL: {page.url}\n"
		f"Labels: {', '.join(page.labels) if page.labels else 'none'}\n"
		f"Chunk {index + 1}/{total}\n"
		f"---\n\n"
	)
	full_content = header + content

	chunk_id = hashlib.sha256(
		f"{page.id}:{index}".encode()
	).hexdigest()[:12]

	return ContentChunk(
		id=chunk_id,
		page_id=page.id,
		page_title=page.title,
		page_url=page.url,
		chunk_index=index,
		total_chunks=total,
		content=full_content,
		token_estimate=estimate_tokens(full_content),
		labels=page.labels,
	)
