/*
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  Author: Steffen70 <steffen@seventy.mx>
  Creation Date: 2024-07-25

  Contributors:
  - Contributor Name <contributor@example.com>
*/

{
  description = "A development environment for working with dotnet 8.";

  inputs = {
    base_flake.url = "git+file:///workspace/game_theory_grpc/base_flake";
    nixpkgs.follows = "base_flake/nixpkgs";
    flake-utils.follows = "base_flake/flake-utils";
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      base_flake,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        unstable = import nixpkgs { inherit system; };

        baseDevShell = base_flake.outputs.devShell.${system};

        buildDependencies = baseDevShell.buildInputs ++ [ unstable.dotnet-sdk_8 ];
      in
      {
        devShell = unstable.mkShell {
          buildInputs = buildDependencies;
          shellHook = baseDevShell.shellHook;
        };

        packages.default = unstable.stdenv.mkDerivation {
          pname = "playing-field-service";
          version = "0.1.0";

          src = ./.;

          buildInputs = buildDependencies;

          buildPhase = ''
            export PROTOBUF_PATH=${base_flake.inputs.protos}
            dotnet publish -c Release -o $out
          '';

          meta = with nixpkgs.lib; {
            description = "The main service of the Game Theory Demo Application.";
            license = licenses.mpl20;
            maintainers = with maintainers; [ steffen70 ];
          };
        };
      }
    );
}
