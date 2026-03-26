"""Normalize Bedrock agent markdown output into a consistent section format."""

import re

SECTIONS = [
    "Overview",
    "Architecture Summary",
    "Identified Resources",
    "Issues & Risks",
    "Technical Debt",
    "Terraform Migration Complexity",
    "Recommended Migration Path",
]


def normalize(md: str, repo: str) -> str:
    blocks = {}
    current = None
    buf = []

    for line in md.splitlines():
        m = re.match(r"^##\s+\d+\.\s+(.+)", line)
        if m:
            if current:
                blocks[current] = "\n".join(buf).strip()
            current = m.group(1)
            buf = []
        elif current:
            buf.append(line)

    if current:
        blocks[current] = "\n".join(buf).strip()

    out = [f"# Repository Assessment: {repo}", ""]
    for i, sec in enumerate(SECTIONS, 1):
        out.append(f"## {i}. {sec}")
        out.append(blocks.get(sec) or "Not Observed")
        out.append("")
    return "\n".join(out)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", required=True)
    parser.add_argument("--input", required=True, help="Raw markdown file")
    parser.add_argument("--output", required=True, help="Normalized output file")
    args = parser.parse_args()

    raw = open(args.input, encoding="utf-8", errors="replace").read()
    result = normalize(raw, args.repo)
    open(args.output, "w", encoding="utf-8").write(result)
