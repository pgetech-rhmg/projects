#!/usr/bin/env python3
"""Test MCP server via SSE."""

import asyncio
import json
import httpx
from mcp import ClientSession, StdioServerParameters
from mcp.client.sse import sse_client

async def test_mcp():
	url = "http://localhost:8000/sse"  # Change to your ALB URL when testing externally
	
	async with httpx.AsyncClient() as http_client:
		async with sse_client(url, http_client) as (read, write):
			async with ClientSession(read, write) as session:
				await session.initialize()
				
				# List available tools
				tools = await session.list_tools()
				print(f"Available tools: {[t.name for t in tools]}")
				
				# Call confluence_search
				result = await session.call_tool(
					"confluence_search",
					arguments={"query": "terraform", "limit": 3}
				)
				print(f"\nSearch results:\n{result.content[0].text}")

if __name__ == "__main__":
	asyncio.run(test_mcp())