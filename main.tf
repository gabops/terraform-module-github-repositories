terraform {
  required_version = "~> 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "github" {
  owner = var.account
}

locals {
  accesses = flatten([
    for repo in var.repositories : [
      for key, value in repo.access : {
        repo       = repo.name
        entity     = key
        permission = value
      }
    ] if length(try(repo.access, {})) > 0
  ])
}

resource "github_repository" "this" {
  for_each               = { for repo in var.repositories : repo.name => repo }
  allow_merge_commit     = try(each.value.allow_merge_commit, var.default_repository_config.allow_merge_commit)
  allow_rebase_merge     = try(each.value.allow_rebase_merge, var.default_repository_config.allow_rebase_merge)
  allow_squash_merge     = try(each.value.allow_squash_merge, var.default_repository_config.allow_squash_merge)
  auto_init              = try(each.value.auto_init, var.default_repository_config.auto_init)
  delete_branch_on_merge = try(each.value.delete_branch_on_merge, var.default_repository_config.delete_branch_on_merge)
  description            = try(each.value.description, null)
  has_downloads          = try(each.value.has_downloads, var.default_repository_config.has_downloads)
  has_issues             = try(each.value.has_issues, var.default_repository_config.has_issues)
  has_projects           = try(each.value.has_projects, var.default_repository_config.has_projects)
  has_wiki               = try(each.value.has_wiki, var.default_repository_config.has_wiki)
  homepage_url           = try(each.value.homepage_url, null)
  license_template       = try(each.value.license_template, null)
  name                   = each.value.name
  visibility             = try(each.value.visibility, var.default_repository_config.visibility)
  vulnerability_alerts   = try(each.value.vulnerability_alerts, var.default_repository_config.vulnerability_alerts)
}

resource "github_branch_protection_v3" "this" {
  depends_on = [
    resource.github_repository.this
  ]
  for_each   = { for repo in var.repositories : repo.name => repo if var.account_type == "organization" }
  repository = each.value.name
  branch     = try(each.value.protected_branch, var.default_repository_config.protected_branch)
  required_pull_request_reviews {
    required_approving_review_count = try(each.value.required_approving_review_count, var.default_repository_config.required_approving_review_count)
  }
  required_status_checks {
    strict = try(each.value.required_status_checks_strict, null)
    contexts = try(each.value.required_status_checks_contexts, null)
  }
}

resource "github_team_repository" "this" {
  depends_on = [
    resource.github_repository.this
  ]
  for_each = { for access in local.accesses : "${access.repo}_${access.entity}" => access }

  repository = each.value.repo
  team_id    = each.value.entity
  permission = each.value.permission
}
