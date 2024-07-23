#!/usr/bin/env bash

generatedDirectory="generated"

# Clear generated directory
rm -rf "./$generatedDirectory"

mkdir -p "./$generatedDirectory"

currentDirectory=${PWD##*/}

# Array of proto files
protosArray=("model" "strategy" "playing_field")

# Base protoc command
protoCommand="python -m grpc_tools.protoc --proto_path=../protos --python_out=./${generatedDirectory} --grpc_python_out=./${generatedDirectory}"

# Add proto files to the command
for proto in "${protosArray[@]}"; do
    protoCommand+=" ../protos/${proto}.proto"
done

# Execute the final protoc command
eval $protoCommand
