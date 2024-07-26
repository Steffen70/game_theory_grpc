#!/usr/bin/env bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Author: Steffen70 <steffen@seventy.mx>
# Creation Date: 2024-07-26
#
# Contributors:
# - Contributor Name <contributor@example.com>

# Check if force flag is provided
FORCE=false
if [ "$1" == "--force" ]; then
  FORCE=true
fi

# Get the directory of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Loop through all directories one layer deep
for dir in "$script_dir"/*/; do
  # Check if the directory contains a .git directory
  if [ -d "$dir/.git" ]; then
    echo "Pushing in repository: $dir"
    if [ "$FORCE" == true ]; then
      (cd "$dir" && git push --force)
    else
      (cd "$dir" && git push)
    fi
  else
    echo "Skipping $dir, not a git repository."
  fi
done

echo "All repositories processed."
