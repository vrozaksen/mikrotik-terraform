# List available recipes
default:
    @just --list

# Fetch secrets from Infisical and write to .env
env:
    infisical export --projectId=da94b011-9a7d-408b-92d9-55be47efe750 --env=prod --format=dotenv --path=/mikrotik > .env
    @echo "✓ .env updated from Infisical (/mikrotik)"
    direnv reload 2>/dev/null || true

# Run terragrunt plan for all modules
plan:
    terragrunt plan --all

# Run terragrunt apply for all modules
apply:
    terragrunt apply --all

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
