import tempfile
from pathlib import Path
from app.checksum import calculate_sha256


def test_calculate_sha256():
    with tempfile.TemporaryDirectory() as tmp:
        file_path = Path(tmp) / "test.txt"
        file_path.write_text("epic")

        result = calculate_sha256(str(file_path))

        assert result == "49a70bd1e731c8cd1f77a9b75803bad6453ea9c6bc1cbc5e32a1dd19aa5d31db"

