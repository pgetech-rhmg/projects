output "id" {
  description = "API ID."
  value       = aws_appsync_graphql_api.graphql_api.id
}

output "arn" {
  description = "ARN."
  value       = aws_appsync_graphql_api.graphql_api.arn
}

output "uris" {
  description = "Map of URIs associated with the APIE.g., uris[GRAPHQL] = https://ID.appsync-api.REGION.amazonaws.com/graphql."
  value       = aws_appsync_graphql_api.graphql_api.uris
}

output "appsync_graphql_api_all" {
  description = "Map of appsync_graphql object."
  value       = aws_appsync_graphql_api.graphql_api
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_appsync_graphql_api.graphql_api.tags_all
}