# List available recipes
default:
    @just --list

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
