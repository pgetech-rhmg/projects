#!/usr/bin/env python3
import asyncio
from mcp import ClientSession
from mcp.client.streamable_http import streamable_http_client

async def test():
	async with streamable_http_client("http://localhost:8000/mcp") as (read, write, _):
		async with ClientSession(read, write) as session:
			await session.initialize()
			
			tools_result = await session.list_tools()
			print(f"Available tools: {[t.name for t in tools_result.tools]}")
			
			result = await session.call_tool("terraform_search", arguments={"query": "s3 lambda", "limit": 1})
			print(f"\nResults:\n{result.content[0].text}")

if __name__ == "__main__":
	asyncio.run(test())