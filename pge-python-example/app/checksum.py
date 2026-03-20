import hashlib
from pathlib import Path


def calculate_sha256(file_path: str) -> str:
    path = Path(file_path)

    if not path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")

    sha256 = hashlib.sha256()

    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            sha256.update(chunk)

    return sha256.hexdigest()


def validate_checksum(file_path: str, expected_hash: str) -> bool:
    actual = calculate_sha256(file_path)
    return actual.lower() == expected_hash.lower()

