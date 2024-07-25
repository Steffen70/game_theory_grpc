#!/usr/bin/env bash

# Get the directory of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Loop through all directories in the script's directory
for dir in "$script_dir"/*/; do
  # Check if the directory contains a flake.nix file
  if [ -f "$dir/flake.nix" ]; then
    echo "Updating flake in directory: $dir"
    (cd "$dir" && nix flake update)
  fi
done

# Update the flake in the script's directory
(cd "$script_dir" && nix flake update)
