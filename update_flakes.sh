#!/usr/bin/env bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Author: Steffen70 <steffen@seventy.mx>
# Creation Date: 2024-07-25
#
# Contributors:
# - Contributor Name <contributor@example.com>

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
