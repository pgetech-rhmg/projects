#!/usr/bin/env python3
"""Test MCP server via SSE."""

import asyncio
import httpx

async def test_mcp():
	url = "https://paige-api.YOUR-DOMAIN.pge.com/sse"
	
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
		
		async with client.stream("POST", url, json=init_req, headers={"Accept": "text/event-stream"}) as response:
			async for line in response.aiter_lines():
				if line.startswith("data: "):
					data = line[6:]
					print(f"Initialize response: {data}")
					break
		
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
		
		async with client.stream("POST", url, json=tool_req, headers={"Accept": "text/event-stream"}) as response:
			async for line in response.aiter_lines():
				if line.startswith("data: "):
					data = line[6:]
					print(f"Tool call response: {data}")

if __name__ == "__main__":
	asyncio.run(test_mcp())