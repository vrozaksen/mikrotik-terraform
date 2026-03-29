# List available recipes
default:
    @just --list

# Fetch secrets from Infisical and write to .env
env:
    infisical export --projectId=da94b011-9a7d-408b-92d9-55be47efe750 --env=prod --format=dotenv --path=/mikrotik > .env
    @echo "✓ .env updated from Infisical (/mikrotik)"
    direnv reload 2>/dev/null || true

# Run terragrunt plan for all modules (summary only)
plan:
    #!/usr/bin/env bash
    terragrunt plan --all 2>&1 | ./scripts/plan-filter.sh

# Run terragrunt plan for all modules (full output)
plan-full:
    terragrunt plan --all

# Run terragrunt plan for local site (router-base, router-services, switch-crs326)
plan-local:
    #!/usr/bin/env bash
    for dir in router-base router-services switch-crs326; do
        echo -e "\n\033[1m=== $dir ===\033[0m"
        (cd infrastructure/mikrotik/$dir && terragrunt plan 2>&1) | ./scripts/plan-filter.sh
    done

# Run terragrunt apply for all modules
apply:
    terragrunt apply --all

# Run terragrunt apply for local site (router-base, router-services, switch-crs326)
apply-local:
    #!/usr/bin/env bash
    for dir in router-base router-services switch-crs326; do
        echo -e "\n\033[1m=== $dir ===\033[0m"
        (cd infrastructure/mikrotik/$dir && terragrunt apply)
    done

# Run terragrunt plan for specific path
plan-path path:
    cd {{path}} && terragrunt plan

# Run terragrunt apply for specific path
apply-path path:
    cd {{path}} && terragrunt apply

# Clean terragrunt cache
clean:
    find infrastructure -type d -name '.terragrunt-cache' -exec rm -rf {} +

# Initialize all modules
init:
    terragrunt init --all
