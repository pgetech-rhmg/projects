#global cluster outputs
output "arn" {
  description = "Global Cluster Amazon Resource Name (ARN)"
  value       = module.global_cluster.arn
}

output "global_cluster_members" {
  description = "Set of objects containing Global Cluster members."
  value       = module.global_cluster.global_cluster_members
}

output "global_cluster_resource_id" {
  description = "AWS Region-unique, immutable identifier for the global database cluster. This identifier is found in AWS CloudTrail log entries whenever the AWS KMS key for the DB cluster is accessed."
  value       = module.global_cluster.global_cluster_resource_id
}

output "id" {
  description = "DocDB Global Cluster."
  value       = module.global_cluster.id
}

#cluster primary outputs
output "primary_docdb_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster."
  value       = module.docdb_cluster_primary.docdb_cluster_arn
}

output "primary_docdb_cluster_cluster_members" {
  description = "List of DocDB Instances that are a part of this cluster."
  value       = module.docdb_cluster_primary.docdb_cluster_cluster_members
}

output "primary_docdb_cluster_resource_id" {
  description = "The DocDB Cluster Resource ID."
  value       = module.docdb_cluster_primary.docdb_cluster_resource_id
}

output "primary_docdb_cluster_endpoint" {
  description = "The DNS address of the DocDB instance."
  value       = module.docdb_cluster_primary.docdb_cluster_endpoint
}

output "primary_docdb_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint."
  value       = module.docdb_cluster_primary.docdb_cluster_hosted_zone_id
}

output "primary_docdb_cluster_id" {
  description = "The DocDB Cluster Identifier."
  value       = module.docdb_cluster_primary.docdb_cluster_id
}

output "primary_docdb_cluster_reader_endpoint" {
  description = "A read-only endpoint for the DocDB cluster, automatically load-balanced across replicas."
  value       = module.docdb_cluster_primary.docdb_cluster_reader_endpoint
}

output "primary_docdb_cluster_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = module.docdb_cluster_primary.docdb_cluster_tags_all
}

#cluster secondary outputs
output "secondary_docdb_cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster."
  value       = module.docdb_cluster_secondary.docdb_cluster_arn
}

output "secondary_docdb_cluster_cluster_members" {
  description = "List of DocDB Instances that are a part of this cluster."
  value       = module.docdb_cluster_secondary.docdb_cluster_cluster_members
}

output "secondary_docdb_cluster_resource_id" {
  description = "The DocDB Cluster Resource ID."
  value       = module.docdb_cluster_secondary.docdb_cluster_resource_id
}

output "secondary_docdb_cluster_endpoint" {
  description = "The DNS address of the DocDB instance."
  value       = module.docdb_cluster_secondary.docdb_cluster_endpoint
}

output "secondary_docdb_cluster_hosted_zone_id" {
  description = "The Route53 Hosted Zone ID of the endpoint."
  value       = module.docdb_cluster_secondary.docdb_cluster_hosted_zone_id
}

output "secondary_docdb_cluster_id" {
  description = "The DocDB Cluster Identifier."
  value       = module.docdb_cluster_secondary.docdb_cluster_id
}

output "secondary_docdb_cluster_reader_endpoint" {
  description = "A read-only endpoint for the DocDB cluster, automatically load-balanced across replicas."
  value       = module.docdb_cluster_secondary.docdb_cluster_reader_endpoint
}

output "secondary_docdb_cluster_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = module.docdb_cluster_secondary.docdb_cluster_tags_all
}

#Outputs for subnet group primary
output "primary_docdb_subnet_group_id" {
  description = "The docdb subnet group name."
  value       = module.subnet_group_primary.docdb_subnet_group_id
}

output "primary_docdb_subnet_group_arn" {
  description = "The ARN of the docdb subnet group."
  value       = module.subnet_group_primary.docdb_subnet_group_arn
}

output "primary_docdb_subnet_group_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = module.subnet_group_primary.docdb_subnet_group_tags_all
}

#Outputs for subnet group secondary
output "secondary_docdb_subnet_group_id" {
  description = "The docdb subnet group name."
  value       = module.subnet_group_secondary.docdb_subnet_group_id
}

output "secondary_docdb_subnet_group_arn" {
  description = "The ARN of the docdb subnet group."
  value       = module.subnet_group_secondary.docdb_subnet_group_arn
}

output "secondary_docdb_subnet_group_tags_all" {
  description = "A map of tags assigned to the resource."
  value       = module.subnet_group_secondary.docdb_subnet_group_tags_all
}

#Outputs for cluster parameter group primary
output "primary_documentdb_cluster_parameter_group_id" {
  description = "The documentDB cluster parameter group name."
  value       = module.cluster_parameter_group_primary.documentdb_cluster_parameter_group_id
}

output "primary_documentdb_cluster_parameter_group_arn" {
  description = "The ARN of the documentDB cluster parameter group."
  value       = module.cluster_parameter_group_primary.documentdb_cluster_parameter_group_arn
}

output "primary_documentdb_cluster_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.cluster_parameter_group_primary.documentdb_cluster_parameter_group_tags_all
}

#Outputs for cluster parameter group secondary
output "secondary_documentdb_cluster_parameter_group_id" {
  description = "The documentDB cluster parameter group name."
  value       = module.cluster_parameter_group_secondary.documentdb_cluster_parameter_group_id
}

output "secondary_documentdb_cluster_parameter_group_arn" {
  description = "The ARN of the documentDB cluster parameter group."
  value       = module.cluster_parameter_group_secondary.documentdb_cluster_parameter_group_arn
}

output "secondary_documentdb_cluster_parameter_group_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = module.cluster_parameter_group_secondary.documentdb_cluster_parameter_group_tags_all
}

#########################################################################################
# commenting code block- global cluster for existing cluster
# for purpuse of example creating global cluster with new cluster 
##########################################################################################

# #global cluster for exisitng cluster outputs
# output "arn_for_existing_cluster" {
#   description = "Global Cluster Amazon Resource Name (ARN)"
#   value       = module.global_cluster_for_existing_cluster.arn_for_existing_cluster
# }

# output "global_cluster_members_for_existing_cluster" {
#   description = "Set of objects containing Global Cluster members."
#   value       = module.global_cluster_for_existing_cluster.global_cluster_members_for_existing_cluster
# }

# output "global_cluster_resource_id_for_existing_cluster" {
#   description = "AWS Region-unique, immutable identifier for the global database cluster. This identifier is found in AWS CloudTrail log entries whenever the AWS KMS key for the DB cluster is accessed."
#   value       = module.global_cluster_for_existing_cluster.global_cluster_resource_id_for_existing_cluster
# }

# output "id_for_existing_cluster" {
#   description = "DocDB Global Cluster."
#   value       = module.global_cluster_for_existing_cluster.id_for_existing_cluster
# }