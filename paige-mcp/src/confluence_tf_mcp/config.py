"""Configuration loader."""
from __future__ import annotations
import json, logging, os
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)

_DEFAULTS = {
	"confluence_base_url": "https://wiki.comp.pge.com",
	"confluence_pat_token": "",
	"confluence_root_page_ids": "",
	"confluence_session_id": "",
	"confluence_seraph": "",
	"confluence_mrh_session": "",
	"kb_path": "./knowledge_base.json",
	"verify_ssl": "true",
}

_ENV_MAP = {
	"confluence_base_url": "CONFLUENCE_BASE_URL",
	"confluence_pat_token": "CONFLUENCE_PAT_TOKEN",
	"confluence_root_page_ids": "CONFLUENCE_ROOT_PAGE_IDS",
	"confluence_session_id": "CONFLUENCE_SESSION_ID",
	"confluence_seraph": "CONFLUENCE_SERAPH",
	"confluence_mrh_session": "CONFLUENCE_MRH_SESSION",
	"kb_path": "KB_PATH",
	"verify_ssl": "VERIFY_SSL",
}


def get_config() -> dict[str, str]:
	config = dict(_DEFAULTS)
	_load_dotenv()
	for key, env_var in _ENV_MAP.items():
		value = os.environ.get(env_var, "")
		if value:
			config[key] = value
	return config


def parse_verify_ssl(value: str) -> bool | str:
	lower = value.lower().strip()
	if lower in ("false", "0", "no", "off"):
		return False
	if lower in ("true", "1", "yes", "on", ""):
		return True
	return value


def parse_page_ids(value: str) -> list[str]:
	"""Parse comma-separated page IDs."""
	if not value.strip():
		return []
	return [pid.strip() for pid in value.split(",") if pid.strip()]


def build_auth_cookies(config: dict[str, str]) -> Optional[dict[str, str]]:
	cookies = {}
	if config.get("confluence_session_id"):
		cookies["JSESSIONID"] = config["confluence_session_id"]
	if config.get("confluence_seraph"):
		cookies["seraph.confluence"] = config["confluence_seraph"]
	if config.get("confluence_mrh_session"):
		cookies["MRHSession"] = config["confluence_mrh_session"]
	return cookies if cookies else None


def _load_dotenv() -> None:
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
					if not line or line.startswith("#") or "=" not in line:
						continue
					key, _, value = line.partition("=")
					key = key.strip()
					value = value.strip()
					if len(value) >= 2 and value[0] == value[-1] and value[0] in ('"', "'"):
						value = value[1:-1]
					if key not in os.environ:
						os.environ[key] = value
			return