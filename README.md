# terraform-module-github-repositories

Terraform module for managing Github repositories.

## Content

`tree -a -I .git .`

```text
.
├── .github                      # Github configuration directory
│   ├── pull_request_template.md # pull request template markdown file
│   └── workflows                # Github Actions configuration
│       └── ci.yml               # CI pipeline configuration 
├── .gitignore                   # git ignore file
├── .terraform-docs.yml          # terraform-docs configuration
├── .terraform.lock.hcl          # terraform lock file
├── Makefile                     # makefile for ease
├── README.md                    # this file
├── examples                     # terraform module examples of use
│   └── docs                     # terraform module examples of use for documentation
│       └── main.tf              # terraform main.tf file for documentation
├── main.tf                      # terraform module main.tf file
├── outputs.tf                   # terraform module outputs.tf file
└── variables.tf                 # terraform module variables.tf file
```

**WARNING:** Please don't change the content below this line.  This is automatically generated by [terraform-docs](https://github.com/terraform-docs/terraform-docs)

<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| github | 5.5.0 |

## Resources

| Name | Type |
|------|------|
| [github_branch_protection.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_team_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account | Account (individual user or organization) where the repositories will be created. | `string` | n/a | yes |
| account\_type | Type of Github account. | `string` | `"user"` | no |
| default\_repository\_config | The default configuration to be applied to all repositories. | `any` | <pre>{<br>  "allow_merge_commit": false,<br>  "allow_rebase_merge": false,<br>  "allow_squash_merge": true,<br>  "auto_init": false,<br>  "branch_protection_rules": [<br>    {<br>      "branch_name_pattern": "main"<br>    }<br>  ],<br>  "delete_branch_on_merge": true,<br>  "has_downloads": false,<br>  "has_issues": false,<br>  "has_projects": false,<br>  "has_wiki": false,<br>  "visibility": "private",<br>  "vulnerability_alerts": true<br>}</pre> | no |
| repositories | List of objects containing the repository definitions. Parameter 'name' is mandatory. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| repository\_names | Names of the repositories. |
| ssh\_clone\_urls | SSH urls for cloning the repositories. |

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.0 |
| github | ~> 5.0 |

## Values

Configuration passed to modules and resources is declared in the file [values.tfvars](./values.tfvars). This file
**must be** treated as the source of truth for the configuration of the infrastructure. Configuration values **must not**
be declared anywhere else other than in this file!

## Development

- This project uses [Semantic Versioning](https://semver.org/).

## Examples

```hcl
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
    branch_protection_rules = [
      {
        branch_name_pattern = "main"
      }
    ]
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
      branch_protection_rules = [
        {
          branch_name_pattern = "master"
          allow_force_pushes  = true
        }
      ]
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
```
<!-- END_TF_DOCS -->
