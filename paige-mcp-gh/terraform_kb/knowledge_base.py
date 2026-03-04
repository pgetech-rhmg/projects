"""KB builder for Terraform modules."""
from __future__ import annotations
import json
import logging
from pathlib import Path
from .crawler import TerraformModuleCrawler
from .models import KnowledgeBase

logger = logging.getLogger(__name__)
DEFAULT_KB_PATH = Path.cwd() / "knowledge_base.json"


async def build_knowledge_base(
	repo_url: str = "https://github.com/pgetech/pge-terraform-modules.git",
	github_token: str | None = None,
	output_path: Path | None = None
) -> KnowledgeBase:
	"""Crawl Terraform modules repo and build KB."""
	output_path = output_path or DEFAULT_KB_PATH
	crawler = TerraformModuleCrawler(repo_url, github_token=github_token)
	
	modules = await crawler.crawl_repo()
	
	if not modules:
		logger.warning("No modules crawled.")
		return KnowledgeBase(source_url=repo_url)
	
	total_examples = sum(len(m.examples) for m in modules.values())
	
	kb = KnowledgeBase(
		source_url=repo_url,
		total_modules=len(modules),
		total_examples=total_examples,
		modules=modules
	)
	
	path = Path(output_path)
	path.parent.mkdir(parents=True, exist_ok=True)
	with open(path, "w") as f:
		f.write(kb.model_dump_json(indent=2))
	
	logger.info(f"Saved: {kb.total_modules} modules, {kb.total_examples} examples")
	return kb


def load_knowledge_base(path: Path | str) -> KnowledgeBase:
	"""Load knowledge base from JSON file."""
	with open(path) as f:
		return KnowledgeBase.model_validate(json.load(f))