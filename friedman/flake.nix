/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 * 
 * Author: Steffen70 <steffen@seventy.mx>
 * Creation Date: 2024-07-25
 * 
 * Contributors:
 * - Contributor Name <contributor@example.com>
 */

{
  description = "A development environment for working with Python and gRPC.";

  inputs = {
    baseFlake.url = "path:../base_flake";
    nixpkgs.follows = "baseFlake/nixpkgs";
    flake-utils.follows = "baseFlake/flake-utils";
  };

  outputs = { self, ... } @ inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        unstable = import inputs.nixpkgs {
          inherit system;
        };

        baseDevShell = inputs.baseFlake.outputs.devShell.${system};

        # Create a custom Python environment with the necessary packages
        myPython = unstable.python312.withPackages (ps: with ps; [
          grpcio
          grpcio-tools
          protobuf
        ]);
      in
      {
        devShell = unstable.mkShell {
          buildInputs = baseDevShell.buildInputs ++ [
            myPython
          ];

          shellHook = baseDevShell.shellHook;
        };
      }
    );
}
