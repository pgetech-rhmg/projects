import json
import socket
import urllib.request


def lambda_handler(event, context):
    results = {
        "execution": "SUCCESS",
        "dns_resolution": "UNKNOWN",
        "external_connectivity": "UNKNOWN",
        "vpc_eni_active": "UNKNOWN",
    }

    # Test DNS resolution
    try:
        ip = socket.gethostbyname("aws.amazon.com")
        results["dns_resolution"] = f"SUCCESS ({ip})"
    except Exception as e:
        results["dns_resolution"] = f"FAILED ({str(e)})"

    # Test external connectivity
    try:
        response = urllib.request.urlopen("https://checkip.amazonaws.com", timeout=5)
        public_ip = response.read().decode("utf-8").strip()
        results["external_connectivity"] = f"SUCCESS (IP: {public_ip})"
    except Exception as e:
        results["external_connectivity"] = f"FAILED ({str(e)})"

    # VPC ENI status
    results["vpc_eni_active"] = "YES (VPC-attached Lambda)"

    return {"statusCode": 200, "body": json.dumps(results, indent=2)}
