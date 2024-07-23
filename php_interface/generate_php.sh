#!/usr/bin/env bash

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
