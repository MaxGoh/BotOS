# BotOS — the entry point for every routine task.
# CI runs `make verify`; keep that target as the single gate.

.DEFAULT_GOAL := help
.PHONY: help bootstrap verify check test clean

help: ## Show this help
	@printf 'BotOS targets:\n\n'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
	@printf '\n'

bootstrap: ## Check the local toolchain (installs nothing yet)
	@./scripts/bootstrap.sh

verify: ## Run the full gate — do this before handing work back
	@./scripts/verify.sh

check: verify ## Alias for verify

test: ## Run the test suite (also run as part of verify)
	@./scripts/test.sh

clean: ## Remove local build artifacts (nothing to clean yet)
	@printf 'Nothing to clean.\n'

.PHONY: feasibility feasibility-host
feasibility: ## Run the credential-free isolation negative control
	@./scripts/feasibility.sh local

feasibility-host: ## Inventory host prerequisites (exit 2: integration gates unvalidated)
	@./scripts/feasibility.sh host
