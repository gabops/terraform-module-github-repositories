module "github_repo" {
  source = "../../"

  account = "myOrg"
  default_repository_config = {
    allow_merge_commit     = false
    allow_rebase_merge     = false
    allow_squash_merge     = true
    auto_init              = false
    delete_branch_on_merge = true
    has_downloads          = false
    has_issues             = false
    has_projects           = false
    has_wiki               = false
    visibility             = "private"
    vulnerability_alerts   = true
    protection = {
      protected_branch = "main"
    }
  }
  repository_definitions = [
    {
      name                 = "foo"
      description          = "Repo for the foo project"
      vulnerability_alerts = false
      access = {
        "team1" = "admin"
        "user1" = "pull"
      },
      protection = {
        protected_branch = "master"
      }
      }, {
      name        = "bar"
      description = "Repo for the bar project."
      access = {
        "team1" = "pull"
        "user1" = "admin"
      }
    }
  ]
}