output "id" {
  value       = local.id
  description = "Normalized id, it is a concat of: customer, application, name, and stage"
}

output "project" {
  value       = local.project
  description = "Normalized project name"
}

output "customer" {
  value       = local.customer
  description = "Normalized customer"
}

output "application" {
  value       = local.application
  description = "Normalized application"
}

output "stage" {
  value       = local.stage
  description = "Normalized stage"
}

output "tags" {
  value       = local.tags
  description = "Normalized Tag map"
}
