help: ## Shows this help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Initializates working directory.
	@terraform init

fmt: ## Rewrites config to canonical format.
	@terraform fmt

lint: ## Lints the HCL code.
	@terraform fmt -diff=true -check

validate: init ## Validates configuration files.
	@terraform validate

docs: ## Generates docs.
	@terraform-docs .
