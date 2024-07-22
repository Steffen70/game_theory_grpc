#!/usr/bin/env bash

generatedDirectory="generated"

# Clear generated directory
rm -rf "./$generatedDirectory"

mkdir -p "./$generatedDirectory"

currentDirectory=${PWD##*/}

# Array of proto files
protosArray=("model" "strategy" "playing_field")

# Base protoc command
protoCommand="protoc --proto_path=../protos --go_out=.. --go-grpc_out=.."

# Add package mapping options for each proto file
for proto in "${protosArray[@]}"; do
    protoCommand+=" --go_opt=M${proto}.proto=${currentDirectory}/${generatedDirectory}/${proto}"
    protoCommand+=" --go-grpc_opt=M${proto}.proto=${currentDirectory}/${generatedDirectory}/${proto}"
done

# Add proto files to the command
for proto in "${protosArray[@]}"; do
    protoCommand+=" ../protos/${proto}.proto"
done

# Execute the final protoc command
eval $protoCommand
