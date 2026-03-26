# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-19

### Added

- Initial release of AWS Bedrock Knowledge Base module
- `aws_bedrockagent_knowledge_base` resource for creating Bedrock Knowledge Bases
- `aws_bedrockagent_data_source` resource for S3 data source integration
- OpenSearch Serverless vector store backend support
- Multiple chunking strategies: FIXED_SIZE, HIERARCHICAL, SEMANTIC, NONE
- Partition-aware ARN construction for multi-region support (AWS, GovCloud, China)
- Comprehensive input validations for IAM roles, OpenSearch collections, and S3 buckets
- RAG application example with end-to-end deployment
- Terraform test framework integration
- PGE mandatory tags enforcement via validate-pge-tags module v0.1.2
- TFLint configuration with PGE tag variable exemptions
