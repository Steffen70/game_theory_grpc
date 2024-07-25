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
protosArray=("model" "strategy" "playing_field")

# Base protoc command
protoCommand="protoc --proto_path=$PROTOBUF_PATH --go_out=.. --go-grpc_out=.."

# Add package mapping options for each proto file
for proto in "${protosArray[@]}"; do
    protoCommand+=" --go_opt=M${proto}.proto=${currentDirectory}/${generatedDirectory}/${proto}"
    protoCommand+=" --go-grpc_opt=M${proto}.proto=${currentDirectory}/${generatedDirectory}/${proto}"
done

# Add proto files to the command
for proto in "${protosArray[@]}"; do
    protoCommand+=" $PROTOBUF_PATH/${proto}.proto"
done

# Execute the final protoc command
eval $protoCommand
