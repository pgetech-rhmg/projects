#!/usr/bin/env python3
"""Test MCP server via SSE."""

import asyncio
import json
import httpx

async def test_mcp():
	base_url = "https://paige-mcp-dev.nonprod.pge.com"
	
	async with httpx.AsyncClient(timeout=30.0) as client:
		# Initialize - get the session endpoint
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
		
		session_endpoint = None
		print("=== INITIALIZE ===")
		async with client.stream("GET", f"{base_url}/sse", headers={"Accept": "text/event-stream"}) as response:
			async for line in response.aiter_lines():
				print(f"Raw: {line}")
				if line.startswith("event: endpoint"):
					continue
				elif line.startswith("data: "):
					data_str = line[6:]
					if data_str.startswith("/messages"):
						session_endpoint = data_str
						print(f"Session endpoint: {session_endpoint}")
					else:
						try:
							data = json.loads(data_str)
							print(f"Response: {json.dumps(data, indent=2)}")
						except:
							print(f"Non-JSON data: {data_str}")
		
		if not session_endpoint:
			print("ERROR: No session endpoint received")
			return
		
		# Call tool using the session endpoint
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
		async with client.stream("POST", f"{base_url}{session_endpoint}", json=tool_req, headers={"Accept": "text/event-stream"}) as response:
			async for line in response.aiter_lines():
				print(f"Raw: {line}")
				if line.startswith("data: "):
					try:
						data = json.loads(line[6:])
						print(f"Response: {json.dumps(data, indent=2)}")
					except:
						pass

if __name__ == "__main__":
	asyncio.run(test_mcp())