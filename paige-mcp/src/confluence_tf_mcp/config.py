"""Configuration loader.

Resolution order:
1. Environment variables (always checked first)
2. .env file in project root (local dev)
3. AWS Secrets Manager (when SECRETS_ARN is set)
4. AWS SSM Parameter Store (when SSM_PREFIX is set)

This keeps secrets out of source control. Locally you use a .env file.
In AWS you use Secrets Manager or SSM -- no code changes needed.
"""

from __future__ import annotations

import json
import logging
import os
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)

# Config keys and their defaults
_DEFAULTS = {
	"confluence_base_url": "https://wiki.comp.pge.com",
	"confluence_pat_token": "",
	"confluence_root_page_id": "",
	"kb_path": "./knowledge_base.json",
	"verify_ssl": "true",
}

# Map config keys to env var names
_ENV_MAP = {
	"confluence_base_url": "CONFLUENCE_BASE_URL",
	"confluence_pat_token": "CONFLUENCE_PAT_TOKEN",
	"confluence_root_page_id": "CONFLUENCE_ROOT_PAGE_ID",
	"kb_path": "KB_PATH",
	"verify_ssl": "VERIFY_SSL",
}


def get_config() -> dict[str, str]:
	"""Load configuration from all sources in priority order."""

	config = dict(_DEFAULTS)

	# 1. Try .env file first (so env vars from it are available)
	_load_dotenv()

	# 2. AWS Secrets Manager (if SECRETS_ARN is set)
	secrets_arn = os.environ.get("SECRETS_ARN", "")
	if secrets_arn:
		aws_secrets = _load_aws_secrets(secrets_arn)
		if aws_secrets:
			config.update(aws_secrets)
			logger.info("Loaded config from AWS Secrets Manager")

	# 3. AWS SSM Parameter Store (if SSM_PREFIX is set)
	ssm_prefix = os.environ.get("SSM_PREFIX", "")
	if ssm_prefix:
		ssm_params = _load_ssm_params(ssm_prefix)
		if ssm_params:
			config.update(ssm_params)
			logger.info("Loaded config from AWS SSM Parameter Store")

	# 4. Environment variables always win (highest priority)
	for key, env_var in _ENV_MAP.items():
		value = os.environ.get(env_var, "")
		if value:
			config[key] = value

	return config


def parse_verify_ssl(value: str) -> bool | str:
	"""Parse VERIFY_SSL config value.

	Returns:
		False if disabled, True if default, or a file path to a CA bundle.
	"""
	lower = value.lower().strip()
	if lower in ("false", "0", "no", "off"):
		return False
	if lower in ("true", "1", "yes", "on", ""):
		return True
	# Treat as path to CA bundle
	return value


def _load_dotenv() -> None:
	"""Load .env file from project root into os.environ."""

	# Walk up from this file to find .env
	env_paths = [
		Path.cwd() / ".env",
		Path(__file__).resolve().parent.parent.parent / ".env",
	]

	for env_path in env_paths:
		if env_path.exists():
			logger.info(f"Loading .env from {env_path}")
			with open(env_path) as f:
				for line in f:
					line = line.strip()
					if not line or line.startswith("#"):
						continue
					if "=" not in line:
						continue
					key, _, value = line.partition("=")
					key = key.strip()
					value = value.strip()
					# Strip surrounding quotes
					if len(value) >= 2 and value[0] == value[-1] and value[0] in ('"', "'"):
						value = value[1:-1]
					# Don't override existing env vars
					if key not in os.environ:
						os.environ[key] = value
			return


def _load_aws_secrets(secret_arn: str) -> Optional[dict[str, str]]:
	"""Load secrets from AWS Secrets Manager.

	Expects the secret value to be a JSON object with keys matching
	our config keys (e.g. confluence_pat_token, confluence_root_page_id).
	"""

	try:
		import boto3
		client = boto3.client("secretsmanager")
		response = client.get_secret_value(SecretId=secret_arn)
		secret_string = response.get("SecretString", "")
		if secret_string:
			data = json.loads(secret_string)
			# Only keep keys we recognize
			return {k: v for k, v in data.items() if k in _DEFAULTS}
	except ImportError:
		logger.debug("boto3 not installed -- skipping AWS Secrets Manager")
	except Exception as e:
		logger.warning(f"Failed to load AWS secret {secret_arn}: {e}")

	return None


def _load_ssm_params(prefix: str) -> Optional[dict[str, str]]:
	"""Load parameters from AWS SSM Parameter Store.

	Expects parameters named like:
		/your-prefix/confluence_pat_token
		/your-prefix/confluence_root_page_id

	All parameters are fetched with decryption enabled.
	"""

	try:
		import boto3
		client = boto3.client("ssm")

		if not prefix.endswith("/"):
			prefix += "/"

		response = client.get_parameters_by_path(
			Path=prefix,
			WithDecryption=True,
			Recursive=False,
		)

		params: dict[str, str] = {}
		for param in response.get("Parameters", []):
			# Extract the key name from the full path
			name = param["Name"].replace(prefix, "")
			if name in _DEFAULTS:
				params[name] = param["Value"]

		return params if params else None

	except ImportError:
		logger.debug("boto3 not installed -- skipping AWS SSM")
	except Exception as e:
		logger.warning(f"Failed to load SSM params from {prefix}: {e}")

	return None
