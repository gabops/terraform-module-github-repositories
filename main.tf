terraform {
  required_version = "~> 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  owner = var.account
}

locals {
  repositories = flatten([
    for repo in var.repositories : [
      merge(var.default_repository_config, repo)
    ]
  ])

  protections = flatten([
    for repo in local.repositories : [
      for rule in try(repo.branch_protection_rules, []) : {
        repo                            = repo.name
        pattern                         = rule.branch_name_pattern
        enforce_admins                  = try(rule.enforce_admins, false)
        require_signed_commits          = try(rule.require_signed_commits, false)
        required_linear_history         = try(rule.required_linear_history, false)
        require_conversation_resolution = try(rule.require_conversation_resolution, false)
        allows_deletions                = try(rule.allows_deletions, false)
        allows_force_pushes             = try(rule.allows_force_pushes, false)
      }
    ]
  ])

  accesses = flatten([
    for repo in local.repositories : [
      for key, value in repo.access : {
        repo       = repo.name
        entity     = key
        permission = value
      }
    ] if length(try(repo.access, {})) > 0
  ])
}

resource "github_repository" "this" {
  for_each = { for repo in local.repositories : repo.name => repo }

  allow_merge_commit     = try(each.value.allow_merge_commit, null)
  allow_rebase_merge     = try(each.value.allow_rebase_merge, null)
  allow_squash_merge     = try(each.value.allow_squash_merge, null)
  auto_init              = try(each.value.auto_init, null)
  delete_branch_on_merge = try(each.value.delete_branch_on_merge, null)
  description            = try(each.value.description, null)
  has_downloads          = try(each.value.has_downloads, null)
  has_issues             = try(each.value.has_issues, null)
  has_projects           = try(each.value.has_projects, null)
  has_wiki               = try(each.value.has_wiki, null)
  homepage_url           = try(each.value.homepage_url, null)
  license_template       = try(each.value.license_template, null)
  name                   = each.value.name
  visibility             = try(each.value.visibility, null)
  vulnerability_alerts   = try(each.value.vulnerability_alerts, null)
}

resource "github_branch_protection" "this" {
  depends_on = [
    github_repository.this
  ]
  for_each = { for protection in local.protections : "${protection.repo}_${protection.pattern}" => protection }

  repository_id                   = each.value.repo
  pattern                         = each.value.pattern
  enforce_admins                  = each.value.enforce_admins
  require_signed_commits          = each.value.require_signed_commits
  required_linear_history         = each.value.required_linear_history
  require_conversation_resolution = each.value.require_conversation_resolution
  allows_deletions                = each.value.allows_deletions
  allows_force_pushes             = each.value.allows_force_pushes
}

resource "github_team_repository" "this" {
  depends_on = [
    github_repository.this
  ]
  for_each = { for access in local.accesses : "${access.repo}_${access.entity}" => access }

  repository = each.value.repo
  team_id    = each.value.entity
  permission = each.value.permission
}