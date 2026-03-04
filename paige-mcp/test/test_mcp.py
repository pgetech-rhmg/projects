#!/usr/bin/env python3
"""Test MCP server via SSE."""

import asyncio
import json
import httpx

async def test_mcp():
	base_url = "https://paige-mcp-dev.nonprod.pge.com"
	
	async with httpx.AsyncClient(timeout=60.0) as client:
		print("=== CONNECTING TO SSE ===")
		
		# Keep SSE connection open
		sse_stream = client.stream("GET", f"{base_url}/sse", headers={"Accept": "text/event-stream"})
		sse_response = await sse_stream.__aenter__()
		
		# Get session endpoint
		session_endpoint = None
		async for line in sse_response.aiter_lines():
			print(f"SSE: {line}")
			if line.startswith("data: ") and line[6:].startswith("/messages"):
				session_endpoint = line[6:]
				print(f"Got session endpoint: {session_endpoint}")
				break
		
		if not session_endpoint:
			print("ERROR: No session endpoint")
			return
		
		# Create background task to listen for responses
		async def listen_responses():
			async for line in sse_response.aiter_lines():
				if line.startswith("event: message"):
					pass
				elif line.startswith("data: "):
					try:
						data = json.loads(line[6:])
						print(f"\n<<< RESPONSE: {json.dumps(data, indent=2)}")
					except:
						print(f"\n<<< DATA: {line[6:]}")
		
		listener = asyncio.create_task(listen_responses())
		
		await asyncio.sleep(1)
		
		# Initialize
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
		await client.post(f"{base_url}{session_endpoint}", json=init_req)
		
		await asyncio.sleep(2)
		
		# Tool call
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
		await client.post(f"{base_url}{session_endpoint}", json=tool_req)
		
		# Wait for responses
		await asyncio.sleep(5)
		
		listener.cancel()
		await sse_stream.__aexit__(None, None, None)

if __name__ == "__main__":
	asyncio.run(test_mcp())