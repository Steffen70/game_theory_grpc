{
  description = "This is a base flake that should be included in all service specific flakes.";

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
