{
  description = "A development environment for working with dotnet 8 and Go.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        unstable = import nixpkgs {
          inherit system;
        };


        # certificateSettings is a JSON string that contains the path to the certificate and the password.
        certificateSettings=''
        {
          "path": "../cert/localhost",
          "password": "fancyspy10"
        }
        '';
      in
      {
        devShell = unstable.mkShell {
          buildInputs = [
            unstable.git
            unstable.dotnet-sdk_8
            unstable.protobuf
            unstable.go
            # Go debugging
            unstable.delve
            # Go protoc plugins
            unstable.protoc-gen-go
            unstable.protoc-gen-go-grpc
          ];

          shellHook = ''
            export PLAYING_FIELD_PORT=5001
            export TIT_FOR_TAT_PORT=5002
            export CERTIFICATE_SETTINGS='${certificateSettings}'
          '';
        };
      }
    );
}