"""Confluence REST API crawler."""
from __future__ import annotations
import asyncio, logging, re
from datetime import datetime
from typing import Optional
import httpx
from bs4 import BeautifulSoup
from .models import ConfluencePage

logger = logging.getLogger(__name__)
_MACRO_RE = re.compile(r"<ac:structured-macro[^>]*>.*?</ac:structured-macro>", re.DOTALL)

class ConfluenceCrawler:
	def __init__(self, base_url, auth_cookies=None, pat_token=None, max_concurrency=3, delay_ms=200, verify_ssl=True):
		self._base_url = base_url.rstrip("/")
		self._api_url = f"{self._base_url}/rest/api"
		self._auth_cookies = auth_cookies
		self._pat_token = pat_token
		self._delay_ms = delay_ms
		self._verify_ssl = verify_ssl
		self._pages = {}
		self._visited = set()
		self._sem = asyncio.Semaphore(max_concurrency)
		if not auth_cookies and not pat_token:
			raise ValueError("Need auth_cookies or pat_token")

	@property
	def pages(self):
		return dict(self._pages)

	def _client(self):
		h = {"Accept": "application/json"}
		if self._pat_token and not self._auth_cookies:
			h["Authorization"] = f"Bearer {self._pat_token}"
		c = None
		if self._auth_cookies:
			c = httpx.Cookies()
			for k, v in self._auth_cookies.items():
				c.set(k, v)
		return httpx.AsyncClient(headers=h, cookies=c, timeout=30.0, follow_redirects=True, verify=self._verify_ssl)

	async def crawl_from_page(self, rid):
		self._pages.clear()
		self._visited.clear()
		async with self._client() as cl:
			await self._crawl(cl, rid, 0)
		logger.info(f"Done: {len(self._pages)} pages")
		return self.pages

	async def _crawl(self, cl, pid, depth):
		if pid in self._visited: return
		self._visited.add(pid)
		async with self._sem:
			pg = await self._fetch(cl, pid)
			if not pg: return
			self._pages[pid] = pg
			logger.info(f"[{len(self._pages)}] d={depth} {pg.title}")
			await asyncio.sleep(self._delay_ms / 1000)
		if pg.child_ids:
			await asyncio.gather(*[self._crawl(cl, c, depth+1) for c in pg.child_ids])

	async def _fetch(self, cl, pid):
		url = f"{self._api_url}/content/{pid}?expand=body.storage,children.page,metadata.labels,version,ancestors"
		try:
			r = await cl.get(url)
			r.raise_for_status()
			d = r.json()
		except Exception as e:
			logger.warning(f"Error fetching {pid}: {e}")
			return None
		html = d.get("body",{}).get("storage",{}).get("value","")
		anc = d.get("ancestors",[])
		lm = None
		vw = d.get("version",{}).get("when")
		if vw:
			try: lm = datetime.fromisoformat(vw.replace("Z","+00:00"))
			except: pass
		return ConfluencePage(
			id=pid, title=d.get("title","Untitled"),
			space_key=d.get("_expandable",{}).get("space","").split("/")[-1] if "_expandable" in d else "",
			html_content=html, plain_text=self._to_text(html),
			url=f"{self._base_url}/pages/viewpage.action?pageId={pid}",
			child_ids=[c["id"] for c in d.get("children",{}).get("page",{}).get("results",[])],
			labels=[l["name"] for l in d.get("metadata",{}).get("labels",{}).get("results",[])],
			parent_id=anc[-1].get("id","") if anc else "", last_modified=lm)

	@staticmethod
	def _to_text(html):
		html = _MACRO_RE.sub("", html)
		soup = BeautifulSoup(html, "html.parser")
		for t in soup.find_all(["script","style"]): t.decompose()
		text = soup.get_text(separator="\n")
		lines = [l.strip() for l in text.splitlines() if l.strip()]
		return "\n".join(lines)