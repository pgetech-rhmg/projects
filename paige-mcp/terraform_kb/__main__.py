"""CLI for Terraform knowledge base builder."""
import asyncio
import logging
import sys
from pathlib import Path
from .knowledge_base import build_knowledge_base, load_knowledge_base

logging.basicConfig(
	level=logging.INFO,
	format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
	datefmt="%Y-%m-%d %H:%M:%S"
)


def main():
	if len(sys.argv) < 2:
		print("Usage:")
		print("  python -m terraform_kb build [output_path]")
		print("  python -m terraform_kb stats [kb_path]")
		sys.exit(1)
	
	command = sys.argv[1]
	
	if command == "build":
		output_path = Path(sys.argv[2]) if len(sys.argv) > 2 else None
		asyncio.run(build_knowledge_base(output_path=output_path))
		print(f"\nKnowledge base written to: {output_path or 'knowledge_base.json'}")
	
	elif command == "stats":
		kb_path = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("knowledge_base.json")
		if not kb_path.exists():
			print(f"Error: {kb_path} not found")
			sys.exit(1)
		
		kb = load_knowledge_base(kb_path)
		print(f"\nKnowledge Base Stats:")
		print(f"  Generated: {kb.generated_at}")
		print(f"  Source: {kb.source_url}")
		print(f"  Modules: {kb.total_modules}")
		print(f"  Examples: {kb.total_examples}")
		print(f"\nModules:")
		for name, module in kb.modules.items():
			print(f"  - {name}: {len(module.examples)} examples")
	
	else:
		print(f"Unknown command: {command}")
		sys.exit(1)


if __name__ == "__main__":
	main()
