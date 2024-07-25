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
  description = "A simple small flake to copy the proto definitions to the nix store.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        unstable = import inputs.nixpkgs { inherit system; };
      in
      {
        packages.default = unstable.stdenv.mkDerivation {
          pname = "proto-definitions";
          version = "0.1.0";

          src = ./.;

          buildPhase = ''
            mkdir -p $out
            cp -r * $out/
          '';

          meta = with unstable.lib; {
            description = "Protobuf definitions for the project.";
            license = licenses.mpl20;
            maintainers = with maintainers; [ steffen70 ];
            platforms = platforms.all;
          };
        };
      }
    );
}
