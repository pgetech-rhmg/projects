#!/usr/bin/env python3
"""Test MCP server via SSE."""

import asyncio
import json
import httpx

async def test_mcp():
	base_url = "https://paige-mcp-dev.nonprod.pge.com"
	
	async with httpx.AsyncClient(timeout=60.0) as client:
		# Step 1: GET /sse to get the session endpoint
		print("=== CONNECTING TO SSE ===")
		session_endpoint = None
		
		async with client.stream("GET", f"{base_url}/sse", headers={"Accept": "text/event-stream"}) as sse_response:
			async for line in sse_response.aiter_lines():
				print(f"SSE: {line}")
				if line.startswith("event: endpoint"):
					pass
				elif line.startswith("data: "):
					data_str = line[6:]
					if data_str.startswith("/messages"):
						session_endpoint = data_str
						print(f"Got session endpoint: {session_endpoint}")
						break
		
		if not session_endpoint:
			print("ERROR: No session endpoint")
			return
		
		# Step 2: POST initialize to the session endpoint
		print("\n=== INITIALIZE ===")
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
		
		resp = await client.post(f"{base_url}{session_endpoint}", json=init_req)
		print(f"Initialize response: {resp.text}")
		
		# Step 3: POST tool call
		print("\n=== TOOL CALL ===")
		tool_req = {
			"jsonrpc": "2.0",
			"id": 2,
			"method": "tools/call",
			"params": {
				"name": "confluence_search",
				"arguments": {"query": "terraform", "limit": 3}
			}
		}
		
		resp = await client.post(f"{base_url}{session_endpoint}", json=tool_req)
		print(f"Tool call response: {resp.text}")

if __name__ == "__main__":
	asyncio.run(test_mcp())