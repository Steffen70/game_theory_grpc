{
  description = "A development environment for working with dotnet 8, PHP and Go.";

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

        # certificateSettings is a JSON string that contains the path to the certificate (without the extension) and the password for the pfx file.
        certificateSettings = ''
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
            unstable.powershell
            unstable.protobuf
            unstable.go
            unstable.delve # Go debugging
            unstable.protoc-gen-go # Go protoc plugin
            unstable.protoc-gen-go-grpc # Go gRPC plugin
          ];

          shellHook = ''
            # Set the shell to PowerShell - vscode will use this shell
            export SHELL="${unstable.powershell}/bin/pwsh"

            export PLAYING_FIELD_PORT=5001
            export TIT_FOR_TAT_PORT=5002

            export CERTIFICATE_SETTINGS='${certificateSettings}'

            # Enter PowerShell
            pwsh

            # Exit when PowerShell exits
            exit 0
          '';
        };
      }
    );
}
