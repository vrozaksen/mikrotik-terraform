#!/usr/bin/env bash
# Filters terragrunt plan output: strips timestamps, shows only changes + summary (preserves color)
sed 's/^.*tofu: //' | awk '{
    s=$0; gsub(/\033\[[0-9;]*m/,"",s)
    if (s ~ /^\s+#.*will be/ || s ~ /^\s+[~+-]/ || s ~ /Plan:/ || s ~ /No changes/ || s ~ /Apply complete/ || s ~ /Error/)
        print
}'
