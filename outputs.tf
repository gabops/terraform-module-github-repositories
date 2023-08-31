output "repository_names" {
  description = "Names of the repositories."
  value       = values(github_repository.this)[*].full_name
}

output "ssh_clone_urls" {
  description = "SSH urls for cloning the repositories."
  value       = values(github_repository.this)[*].ssh_clone_url
}

output "http_clone_urls" {
  description = "HTTP urls for cloning the repositories."
  value       = values(github_repository.this)[*].http_clone_url
}
