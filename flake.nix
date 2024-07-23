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

        # Create a custom PHP build with the grpc extension and custom configuration
        myPhp = unstable.php.withExtensions (exts: [
          unstable.php.extensions.grpc
          unstable.php.extensions.protobuf
        ]);

        # certificateSettings is a JSON string that contains the path to the certificate and the password for the pfx file.
        # - the path is defined without the extension
        # - Go and PHP will use the .crt and .key files
        # - C# will use the .pfx file with the password
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
            unstable.dotnet-sdk_8
            unstable.protobuf
            unstable.go
            unstable.delve # Go debugging
            unstable.protoc-gen-go # Go protoc plugin
            unstable.protoc-gen-go-grpc # Go gRPC plugin
            unstable.grpc # C based gRPC
            myPhp
            unstable.php83Packages.composer # PHP dependency manager
          ];

          shellHook = ''
            # Set the shell to PowerShell - vscode will use this shell
            export SHELL="${unstable.powershell}/bin/pwsh"

            export PHP_INTERFACE_PORT=5000
            export PLAYING_FIELD_PORT=5001
            export TIT_FOR_TAT_PORT=5002
            export FRIEDMAN_PORT=5003

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
