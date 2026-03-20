import sys
from app.checksum import calculate_sha256, validate_checksum


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: python main.py <file> [expected_hash]")
        return 1

    file_path = sys.argv[1]

    try:
        actual_hash = calculate_sha256(file_path)
        print(f"SHA256: {actual_hash}")

        if len(sys.argv) == 3:
            expected = sys.argv[2]
            if not validate_checksum(file_path, expected):
                print("❌ Checksum mismatch")
                return 2
            print("✅ Checksum validated")

        return 0

    except Exception as ex:
        print(f"Error: {ex}")
        return 3


if __name__ == "__main__":
    sys.exit(main())

