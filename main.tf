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
        blocks_creations                = try(rule.blocks_creations, false)
        required_status_checks          = try(rule.required_status_checks, {})
        required_pull_request_reviews   = try(rule.required_pull_request_reviews, {})
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

  webhooks = flatten([
    for repo in local.repositories : [
      for webhook in try(repo.webhooks, []) : {
        repo         = repo.name
        active       = try(webhook.active, null)
        events       = webhook.events
        url          = webhook.url
        content_type = webhook.content_type
        insecure_ssl = try(webhook.insecure_ssl, null)
      }
    ]
  ])

  actions_repository_secrets = flatten([
    for repo in local.repositories : [
      for secret in try(repo.actions_repository_secrets, []) : {
        repo            = repo.name
        secret_name     = secret.secret_name
        encrypted_value = try(secret.encrypted_value, null)
        plaintext_value = try(secret.plaintext_value, null)
      }
    ]
  ])
}

resource "github_repository" "this" {
  for_each = { for repo in local.repositories : repo.name => repo }

  allow_merge_commit     = try(each.value.allow_merge_commit, null)
  allow_rebase_merge     = try(each.value.allow_rebase_merge, null)
  allow_squash_merge     = try(each.value.allow_squash_merge, null)
  allow_update_branch    = try(each.value.allow_update_branch, true)
  auto_init              = try(each.value.auto_init, null)
  delete_branch_on_merge = try(each.value.delete_branch_on_merge, null)
  description            = try(each.value.description, null)
  has_downloads          = try(each.value.has_downloads, null)
  has_issues             = try(each.value.has_issues, null)
  has_projects           = try(each.value.has_projects, null)
  has_wiki               = try(each.value.has_wiki, null)
  homepage_url           = try(each.value.homepage_url, null)
  license_template       = try(each.value.license_template, null)
  merge_commit_message   = try(each.value.merge_commit_message, null)
  merge_commit_title     = try(each.value.merge_commit_title, null)
  name                   = each.value.name
  squash_merge_commit_message = try(each.value.squash_merge_commit_message, null)
  squash_merge_commit_title   = try(each.value.squash_merge_commit_title, null)
  topics                      = try(each.value.topics, [])
  visibility             = try(each.value.visibility, null)
  vulnerability_alerts   = try(each.value.vulnerability_alerts, null)

  dynamic "template" {
    for_each = try(each.value.template, {}) != {} ? [1] : []

    content {
      include_all_branches = try(each.value.template.include_all_branches, null)
      owner                = try(each.value.template.owner, null)
      repository           = try(each.value.template.repository, null)
    }
  }

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
  blocks_creations                = each.value.blocks_creations

  dynamic "required_status_checks" {
    for_each = each.value.required_status_checks != {} ? [1] : []
    content {
      strict   = try(each.value.required_status_checks.strict, null)
      contexts = try(each.value.required_status_checks.contexts, null)
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = each.value.required_pull_request_reviews != {} ? [1] : []

    content {
      dismiss_stale_reviews           = try(each.value.required_pull_request_reviews.dismiss_stale_reviews, null)
      restrict_dismissals             = try(each.value.required_pull_request_reviews.restrict_dismissals, null)
      dismissal_restrictions          = try(each.value.required_pull_request_reviews.dismissal_restrictions, [])
      pull_request_bypassers          = try(each.value.required_pull_request_reviews.pull_request_bypassers, [])
      require_code_owner_reviews      = try(each.value.required_pull_request_reviews.require_code_owner_reviews, null)
      required_approving_review_count = try(each.value.required_pull_request_reviews.required_approving_review_count, null)
    }
  }
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

resource "github_repository_webhook" "this" {
  depends_on = [
    github_repository.this
  ]
  for_each = { for webhook in local.webhooks : "${webhook.repo}_${webhook.url}" => webhook }

  repository = each.value.repo
  active     = each.value.active
  events     = each.value.events

  configuration {
    url          = each.value.url
    content_type = each.value.content_type
    insecure_ssl = each.value.insecure_ssl
  }
}

resource "github_actions_secret" "this" {
  depends_on = [
    github_repository.this
  ]
  for_each = { for secret in local.actions_repository_secrets : "${secret.repo}_${secret.secret_name}" => secret }

  repository      = each.value.repo
  secret_name     = each.value.secret_name
  encrypted_value = each.value.encrypted_value
  plaintext_value = each.value.plaintext_value
}
