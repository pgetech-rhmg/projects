"""Confluence REST API crawler.

Recursively crawls pages from a Confluence instance starting from a root page ID.
Uses the REST API (not HTML scraping) for structured content extraction.
"""

from __future__ import annotations

import asyncio
import logging
import re
from datetime import datetime
from typing import Optional

import httpx
from bs4 import BeautifulSoup

from .models import ConfluencePage

logger = logging.getLogger(__name__)

# Confluence storage format macros to strip
_MACRO_PATTERN = re.compile(
	r"<ac:structured-macro[^>]*>.*?</ac:structured-macro>",
	re.DOTALL,
)
_WHITESPACE_COLLAPSE = re.compile(r"\s+")


class ConfluenceCrawler:
	"""Crawls Confluence pages via REST API starting from a root page."""

	def __init__(
		self,
		base_url: str,
		pat_token: str,
		max_concurrency: int = 3,
		delay_ms: int = 200,
	) -> None:
		self._base_url = base_url.rstrip("/")
		self._api_url = f"{self._base_url}/rest/api"
		self._pat_token = pat_token
		self._max_concurrency = max_concurrency
		self._delay_ms = delay_ms
		self._pages: dict[str, ConfluencePage] = {}
		self._visited: set[str] = set()
		self._semaphore = asyncio.Semaphore(max_concurrency)

	@property
	def pages(self) -> dict[str, ConfluencePage]:
		return dict(self._pages)

	def _build_client(self) -> httpx.AsyncClient:
		return httpx.AsyncClient(
			headers={
				"Authorization": f"Bearer {self._pat_token}",
				"Accept": "application/json",
			},
			timeout=30.0,
			follow_redirects=True,
		)

	async def crawl_from_page(self, root_page_id: str) -> dict[str, ConfluencePage]:
		"""Crawl all pages starting from root_page_id, following child links recursively."""

		self._pages.clear()
		self._visited.clear()

		async with self._build_client() as client:
			await self._crawl_recursive(client, root_page_id, depth=0)

		logger.info(f"Crawl complete: {len(self._pages)} pages collected")
		return self.pages

	async def _crawl_recursive(
		self,
		client: httpx.AsyncClient,
		page_id: str,
		depth: int,
	) -> None:
		if page_id in self._visited:
			return
		self._visited.add(page_id)

		async with self._semaphore:
			page = await self._fetch_page(client, page_id)
			if page is None:
				return

			self._pages[page_id] = page
			logger.info(f"[{len(self._pages)}] depth={depth} {page.title} ({len(page.plain_text)} chars)")

			await asyncio.sleep(self._delay_ms / 1000)

		# Crawl children in parallel (bounded by semaphore)
		if page.child_ids:
			tasks = [
				self._crawl_recursive(client, child_id, depth + 1)
				for child_id in page.child_ids
			]
			await asyncio.gather(*tasks)

	async def _fetch_page(
		self,
		client: httpx.AsyncClient,
		page_id: str,
	) -> Optional[ConfluencePage]:
		"""Fetch a single page with its body and children."""

		url = (
			f"{self._api_url}/content/{page_id}"
			f"?expand=body.storage,children.page,metadata.labels,version,ancestors"
		)

		try:
			resp = await client.get(url)
			resp.raise_for_status()
			data = resp.json()
		except httpx.HTTPStatusError as e:
			logger.warning(f"HTTP {e.response.status_code} fetching page {page_id}")
			return None
		except Exception as e:
			logger.warning(f"Error fetching page {page_id}: {e}")
			return None

		# Extract fields
		title = data.get("title", "Untitled")

		html_content = (
			data.get("body", {})
			.get("storage", {})
			.get("value", "")
		)

		plain_text = self._html_to_text(html_content)

		child_ids = [
			child["id"]
			for child in (
				data.get("children", {})
				.get("page", {})
				.get("results", [])
			)
		]

		labels = [
			label["name"]
			for label in (
				data.get("metadata", {})
				.get("labels", {})
				.get("results", [])
			)
		]

		parent_id = ""
		ancestors = data.get("ancestors", [])
		if ancestors:
			parent_id = ancestors[-1].get("id", "")

		space_key = data.get("_expandable", {}).get("space", "").split("/")[-1] if "_expandable" in data else ""

		last_modified = None
		version_when = data.get("version", {}).get("when")
		if version_when:
			try:
				last_modified = datetime.fromisoformat(version_when.replace("Z", "+00:00"))
			except (ValueError, TypeError):
				pass

		page_url = f"{self._base_url}/pages/viewpage.action?pageId={page_id}"

		return ConfluencePage(
			id=page_id,
			title=title,
			space_key=space_key,
			html_content=html_content,
			plain_text=plain_text,
			url=page_url,
			child_ids=child_ids,
			labels=labels,
			parent_id=parent_id,
			last_modified=last_modified,
		)

	@staticmethod
	def _html_to_text(html: str) -> str:
		"""Convert Confluence storage format HTML to clean plain text."""

		# Strip Confluence macros first
		html = _MACRO_PATTERN.sub("", html)

		soup = BeautifulSoup(html, "html.parser")

		# Remove script/style tags
		for tag in soup.find_all(["script", "style"]):
			tag.decompose()

		# Preserve code blocks
		for code_block in soup.find_all("ac:plain-text-body"):
			code_block.replace_with(f"\n```\n{code_block.get_text()}\n```\n")

		# Preserve table structure
		for table in soup.find_all("table"):
			rows = []
			for tr in table.find_all("tr"):
				cells = [td.get_text(strip=True) for td in tr.find_all(["td", "th"])]
				rows.append(" | ".join(cells))
			table.replace_with("\n" + "\n".join(rows) + "\n")

		# Preserve headings
		for level in range(1, 7):
			for heading in soup.find_all(f"h{level}"):
				prefix = "#" * level
				heading.replace_with(f"\n{prefix} {heading.get_text(strip=True)}\n")

		# Preserve list items
		for li in soup.find_all("li"):
			li.replace_with(f"\n- {li.get_text(strip=True)}")

		text = soup.get_text(separator="\n")

		# Clean up whitespace while preserving paragraph breaks
		lines = []
		for line in text.splitlines():
			stripped = line.strip()
			if stripped:
				lines.append(stripped)
			elif lines and lines[-1] != "":
				lines.append("")

		return "\n".join(lines).strip()
