"""Github Terraform modules crawler."""
from __future__ import annotations
import asyncio
import logging
import tempfile
from pathlib import Path
from typing import Optional
from .models import TerraformExample, TerraformModule

logger = logging.getLogger(__name__)


class TerraformModuleCrawler:
	def __init__(self, repo_url: str = "https://github.com/pgetech/pge-terraform-modules.git", 
	             github_token: str | None = None,
	             max_concurrency: int = 3):
		self._sem = asyncio.Semaphore(max_concurrency)
		self._modules = {}
		
		# Inject token into URL if provided
		if github_token:
			self._repo_url = repo_url.replace("https://", f"https://{github_token}@")
		else:
			self._repo_url = repo_url

	@property
	def modules(self):
		return dict(self._modules)

	async def crawl_repo(self):
		"""Clone repo and crawl aws/modules structure."""
		self._modules.clear()
		
		with tempfile.TemporaryDirectory() as tmpdir:
			repo_path = Path(tmpdir) / "repo"
			
			# Shallow clone
			logger.info(f"Cloning {self._repo_url} (shallow, main branch)...")
			proc = await asyncio.create_subprocess_exec(
				"git", "clone", "--depth", "1", "--branch", "main", self._repo_url, str(repo_path),
				stdout=asyncio.subprocess.PIPE,
				stderr=asyncio.subprocess.PIPE
			)
			stdout, stderr = await proc.communicate()
			
			if proc.returncode != 0:
				raise RuntimeError(f"Git clone failed: {stderr.decode()}")
			
			logger.info("Clone complete. Scanning aws/modules...")
			
			# Find all example folders under aws/modules/*/examples/*
			aws_modules_path = repo_path / "aws" / "modules"
			
			if not aws_modules_path.exists():
				logger.warning(f"Path not found: {aws_modules_path}")
				return self.modules
			
			for module_dir in aws_modules_path.iterdir():
				if not module_dir.is_dir():
					continue
				
				examples_dir = module_dir / "examples"
				if not examples_dir.exists():
					continue
				
				module_name = module_dir.name
				logger.info(f"Processing module: {module_name}")
				
				examples = []
				for example_dir in examples_dir.iterdir():
					if not example_dir.is_dir():
						continue
					
					example = await self._process_example(module_name, example_dir)
					if example:
						examples.append(example)
				
				if examples:
					self._modules[module_name] = TerraformModule(
						name=module_name,
						examples=examples
					)
		
		logger.info(f"Done: {len(self._modules)} modules, {sum(len(m.examples) for m in self._modules.values())} examples")
		return self.modules

	async def _process_example(self, module_name: str, example_path: Path) -> Optional[TerraformExample]:
		"""Process a single example folder."""
		example_name = example_path.name
		
		# Read all .tf files
		tf_files = {}
		for tf_file in example_path.glob("*.tf"):
			try:
				content = tf_file.read_text(encoding="utf-8")
				tf_files[tf_file.name] = content
			except Exception as e:
				logger.warning(f"Failed to read {tf_file}: {e}")
		
		if not tf_files:
			logger.debug(f"No .tf files in {example_path}")
			return None
		
		# Read README if exists
		readme_content = ""
		readme_path = example_path / "README.md"
		if readme_path.exists():
			try:
				readme_content = readme_path.read_text(encoding="utf-8")
			except Exception as e:
				logger.warning(f"Failed to read README: {e}")
		
		# Read any .json policy files
		json_files = {}
		for json_file in example_path.glob("*.json"):
			try:
				content = json_file.read_text(encoding="utf-8")
				json_files[json_file.name] = content
			except Exception as e:
				logger.warning(f"Failed to read {json_file}: {e}")
		
		logger.info(f"  [{module_name}] {example_name}: {len(tf_files)} .tf files")
		
		return TerraformExample(
			name=example_name,
			module_name=module_name,
			terraform_files=tf_files,
			json_files=json_files,
			readme=readme_content
		)