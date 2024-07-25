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

generatedDirectory="generated"

# Clear generated directory
rm -rf "./$generatedDirectory"

mkdir -p "./$generatedDirectory"

currentDirectory=${PWD##*/}

# Array of proto files
protosArray=("model" "playing_field")

# Base protoc command
# - the grpc_php_plugin only generates the client stubs
protoCommand="protoc --proto_path=../protos --php_out=./${generatedDirectory} --grpc_out=./${generatedDirectory} --plugin=protoc-gen-grpc=$(which grpc_php_plugin)"

# Add proto files to the command
for proto in "${protosArray[@]}"; do
    protoCommand+=" ../protos/${proto}.proto"
done

# Execute the final protoc command
eval $protoCommand

# Generate the autoload file to import the generated files
composer dump-autoload
