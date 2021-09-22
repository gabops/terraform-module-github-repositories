module "github_repo" {
  source = "../../"

  account = "myOrg"
  repository_definitions = [
    {
      name        = "foo"
      description = "Repo for the foo project"
      access = {
        "team1" = "admin"
        "user1" = "pull"
      }
    }, {
      name        = "bar"
      description = "Repo for the bar project."
      access = {
        "team1" = "pull"
        "user1" = "admin"
      }, {
        name        = "another-repo"
        description = "Another repo." // If access is not declared, the user who runs terraform will be set as admin.
      }, {
        name        = "another-repo"
        description = "Another repo."
      }
    }
  ]
}