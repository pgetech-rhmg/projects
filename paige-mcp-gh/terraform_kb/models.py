"""Data models for the Terraform knowledge base."""
from __future__ import annotations
from datetime import datetime
from typing import Dict
from pydantic import BaseModel, Field, ConfigDict


class TerraformExample(BaseModel):
	"""A single example from a Terraform module."""
	model_config = ConfigDict(frozen=True)
	
	name: str
	module_name: str
	terraform_files: Dict[str, str] = Field(default_factory=dict)
	json_files: Dict[str, str] = Field(default_factory=dict)
	readme: str = ""


class TerraformModule(BaseModel):
	"""A Terraform module with multiple examples."""
	model_config = ConfigDict(frozen=True)
	
	name: str
	examples: list[TerraformExample] = Field(default_factory=list)


class KnowledgeBase(BaseModel):
	"""The full crawled Terraform modules knowledge base."""
	
	generated_at: datetime = Field(default_factory=datetime.utcnow)
	source_url: str
	total_modules: int = 0
	total_examples: int = 0
	modules: Dict[str, TerraformModule] = Field(default_factory=dict)