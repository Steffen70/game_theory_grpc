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

# Get the directory of the script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of subdirectories to be committed
subdirs=("base_flake" "friedman" "php_interface" "playing_field" "tit_for_tat")

# Function to commit a sub-repository
commit_subrepo() {
  local subdir=$1
  if [ -d "$script_dir/$subdir/.git" ]; then
    echo "Committing in sub-repository: $subdir"
    if [ -z "$commit_message" ]; then
      (cd "$script_dir/$subdir" && git add . && git commit --amend --no-edit)
    else
      (cd "$script_dir/$subdir" && git add . && git commit -m "$commit_message")
    fi
  else
    echo "Skipping $subdir, not a git repository."
  fi
}

# Loop through each subdirectory and commit
for subdir in "${subdirs[@]}"; do
  commit_subrepo "$subdir"
done

# Commit the main repository
echo "Committing in the main repository"
if [ -z "$commit_message" ]; then
  (cd "$script_dir" && git add . && git commit --amend --no-edit)
else
  (cd "$script_dir" && git add . && git commit -m "$commit_message")
fi

echo "All repositories committed with message: '${commit_message:-amended last commit}'"
