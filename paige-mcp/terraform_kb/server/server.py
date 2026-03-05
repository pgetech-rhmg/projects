#!/usr/bin/env python3
"""Terraform modules MCP Server."""

from __future__ import annotations

import contextlib
import json
import logging
import os
import sys
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Optional

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import PlainTextResponse
from mcp.server.fastmcp import FastMCP

from ..models import KnowledgeBase, TerraformModule, TerraformExample

logger = logging.getLogger(__name__)

KB_PATH = Path(os.environ.get("KB_PATH", Path(__file__).parent.parent / "knowledge_base.json"))

_kb: Optional[KnowledgeBase] = None


def _load_kb() -> KnowledgeBase:
	if not KB_PATH.exists():
		raise FileNotFoundError(f"Knowledge base not found at {KB_PATH}")
	with open(KB_PATH) as f:
		return KnowledgeBase.model_validate(json.load(f))


def _search_modules(modules: dict[str, TerraformModule], query: str, limit: int = 10) -> list[TerraformExample]:
	"""Search for examples matching query terms. Returns up to limit examples per matched service."""
	query_terms = [t.lower() for t in query.replace("terraform", "").strip().split()]
	results = []
	
	for term in query_terms:
		# Direct module name match
		if term in modules:
			# Take only 'limit' examples from this module
			results.extend(modules[term].examples[:limit])
	
	return results


def _format_example(example: TerraformExample) -> str:
	"""Format a single example with focus on standards and implementation."""
	content = []
	
	# Start with module context
	content.append(f"## {example.module_name.upper()} Module Standards\n")
	
	# README contains the actual standards - extract and clean it
	if example.readme:
		# Strip the markdown table formatting but keep the info
		readme_clean = example.readme.replace("<!-- BEGIN_TF_DOCS -->", "").replace("<!-- END_TF_DOCS -->", "").strip()
		content.append(f"{readme_clean}\n")
	
	# Show the actual implementation patterns
	content.append(f"\n### Reference Implementation: {example.name}\n")
	
	# Main.tf is the most important - show variable usage, module calls, resource patterns
	if "main.tf" in example.terraform_files:
		content.append("#### Pattern (main.tf):")
		content.append(example.terraform_files["main.tf"])
		content.append("")
	
	# Variables show naming conventions and required inputs
	if "variables.tf" in example.terraform_files:
		content.append("#### Variables (variables.tf):")
		content.append(example.terraform_files["variables.tf"])
		content.append("")
	
	# Outputs show what to expose
	if "outputs.tf" in example.terraform_files:
		content.append("#### Outputs (outputs.tf):")
		content.append(example.terraform_files["outputs.tf"])
		content.append("")
	
	# Supporting files (policies, etc.)
	if example.json_files:
		content.append("#### Supporting Files:")
		for filename, filecontent in example.json_files.items():
			content.append(f"\n{filename}:")
			content.append(filecontent)
			content.append("")
	
	return "\n".join(content)


def _format_examples(examples: list[TerraformExample]) -> str:
	"""Format multiple examples as markdown."""
	if not examples:
		return "No results found."
	return "\n\n---\n\n".join(_format_example(ex) for ex in examples)


# ── MCP Server Setup ─────────────────────────────────────────────────────────

mcp = FastMCP(
	"terraform_modules_mcp",
	stateless_http=True,
	json_response=True
)


@mcp.tool()
def terraform_search(query: str, limit: int = 3) -> str:
	"""Search Terraform modules by AWS service name."""
	results = _search_modules(_kb.modules, query, limit)
	if not results:
		return f"No results for '{query}'."
	return f"## Search: '{query}' ({len(results)} examples)\n\n" + _format_examples(results)


@mcp.tool()
def terraform_get_module(module_name: str) -> str:
	"""Get all examples for a specific module."""
	if module_name not in _kb.modules:
		return f"Module '{module_name}' not found."
	
	module = _kb.modules[module_name]
	return _format_examples(module.examples)


@mcp.tool()
def terraform_list_modules() -> str:
	"""List all available Terraform modules."""
	modules_info = []
	for name, module in _kb.modules.items():
		modules_info.append({
			"name": name,
			"examples": len(module.examples)
		})
	
	return json.dumps({
		"total_modules": len(_kb.modules),
		"modules": sorted(modules_info, key=lambda x: x["name"])
	}, indent=2)


@mcp.tool()
def terraform_kb_stats() -> str:
	"""Get knowledge base statistics."""
	return json.dumps({
		"source_url": _kb.source_url,
		"generated_at": _kb.generated_at.isoformat(),
		"total_modules": _kb.total_modules,
		"total_examples": _kb.total_examples,
		"modules": {name: len(mod.examples) for name, mod in _kb.modules.items()}
	}, indent=2, default=str)


# ── FastAPI App ──────────────────────────────────────────────────────────────

@asynccontextmanager
async def app_lifespan(app: FastAPI):
	global _kb
	logger.info(f"Loading knowledge base from {KB_PATH}")
	_kb = _load_kb()
	logger.info(f"Loaded: {_kb.total_modules} modules, {_kb.total_examples} examples")
	yield


# Create MCP app first
mcp_app = mcp.streamable_http_app()

# Combine both lifespans manually
@asynccontextmanager
async def combined_lifespan(app: FastAPI):
	async with contextlib.AsyncExitStack() as stack:
		# Enter MCP's session manager
		await stack.enter_async_context(mcp.session_manager.run())
		# Enter app lifespan
		await stack.enter_async_context(app_lifespan(app))
		yield

app = FastAPI(lifespan=combined_lifespan)

# Add CORS middleware
app.add_middleware(
	CORSMiddleware,
	allow_origins=["*"],
	allow_credentials=True,
	allow_methods=["*"],
	allow_headers=["*"],
)


@app.get("/health")
async def health():
	return PlainTextResponse("healthy")


@app.post("/api/terraform/search")
async def search_api(query: str, limit: int = 3):
	"""Direct HTTP endpoint for .NET clients - bypasses MCP protocol"""
	if not _kb:
		return {"error": "Knowledge base not loaded"}
	
	results = _search_modules(_kb.modules, query, limit)
	return {
		"query": query,
		"count": len(results),
		"content": _format_examples(results)
	}


# Mount MCP server
app.mount("/", mcp_app)


# ── Entrypoint ───────────────────────────────────────────────────────────────

def main() -> None:
	import uvicorn
	logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(name)s] %(levelname)s: %(message)s", stream=sys.stderr)
	uvicorn.run(app, host="0.0.0.0", port=8000)


if __name__ == "__main__":
	main()