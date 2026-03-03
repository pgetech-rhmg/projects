"""Data models for the Confluence knowledge base."""

from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field, ConfigDict


class ConfluencePage(BaseModel):
	"""A single page crawled from Confluence."""

	model_config = ConfigDict(frozen=True)

	id: str
	title: str
	space_key: str
	html_content: str = Field(default="", exclude=True)
	plain_text: str
	url: str
	child_ids: list[str] = Field(default_factory=list)
	labels: list[str] = Field(default_factory=list)
	parent_id: str = ""
	last_modified: Optional[datetime] = None
	scraped_at: datetime = Field(default_factory=datetime.utcnow)


class ContentChunk(BaseModel):
	"""A chunk of content sized for LLM context windows."""

	model_config = ConfigDict(frozen=True)

	id: str
	page_id: str
	page_title: str
	page_url: str
	chunk_index: int
	total_chunks: int
	content: str
	token_estimate: int
	labels: list[str] = Field(default_factory=list)


class KnowledgeBase(BaseModel):
	"""The full crawled and chunked knowledge base."""

	generated_at: datetime = Field(default_factory=datetime.utcnow)
	source_url: str
	root_page_id: str
	total_pages: int = 0
	total_chunks: int = 0
	estimated_tokens: int = 0
	pages: dict[str, ConfluencePage] = Field(default_factory=dict)
	chunks: list[ContentChunk] = Field(default_factory=list)
