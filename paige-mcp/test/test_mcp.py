#!/usr/bin/env python3
"""Test MCP server via SSE."""

import asyncio
import json
import httpx

async def test_mcp():
	url = "https://paige-mcp-dev.nonprod.pge.com/sse"
	
	async with httpx.AsyncClient(timeout=30.0) as client:
		# Initialize
		init_req = {
			"jsonrpc": "2.0",
			"id": 1,
			"method": "initialize",
			"params": {
				"protocolVersion": "2024-11-05",
				"capabilities": {},
				"clientInfo": {"name": "test", "version": "1.0"}
			}
		}
		
		print("=== INITIALIZE ===")
		async with client.stream("POST", url, json=init_req, headers={"Accept": "text/event-stream"}) as response:
			async for line in response.aiter_lines():
				print(f"Raw line: {line}")
				if line.startswith("data: "):
					data = json.loads(line[6:])
					print(f"Parsed: {json.dumps(data, indent=2)}")
		
		# Call tool
		tool_req = {
			"jsonrpc": "2.0",
			"id": 2,
			"method": "tools/call",
			"params": {
				"name": "confluence_search",
				"arguments": {"query": "terraform", "limit": 3}
			}
		}
		
		print("\n=== TOOL CALL ===")
		async with client.stream("POST", url, json=tool_req, headers={"Accept": "text/event-stream"}) as response:
			async for line in response.aiter_lines():
				print(f"Raw line: {line}")
				if line.startswith("data: "):
					data = json.loads(line[6:])
					print(f"Parsed: {json.dumps(data, indent=2)}")

if __name__ == "__main__":
	asyncio.run(test_mcp())