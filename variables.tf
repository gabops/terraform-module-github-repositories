variable "account" {
  description = "Account (individual user or organization) where the repositories will be created."
  type        = string
}

variable "account_type" {
  description = "Type of Github account."
  type        = string
  default     = "user"
  validation {
    condition     = var.account_type != "user" || var.account_type != "organization"
    error_message = "The account type value must be 'user' or 'organization'."
  }
}

variable "default_repository_config" {
  description = "The default configuration to be applied to all repositories. Any value here can be overwritten from a repository definition in 'repositories' variable."
  type        = map(string)
  default = {
    allow_merge_commit              = false
    allow_rebase_merge              = false
    allow_squash_merge              = true
    auto_init                       = false
    delete_branch_on_merge          = true
    has_downloads                   = false
    has_issues                      = false
    has_projects                    = false
    has_wiki                        = false
    protected_branch                = "main"
    required_approving_review_count = 1
    visibility                      = "private"
    vulnerability_alerts            = true
  }
}

variable "repositories" {
  description = "List of objects containing the repository definitions. Parameter 'name' is mandatory."
  type        = any
}
