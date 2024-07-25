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
  description = "A development environment for working with dotnet 8.";

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
      in
      {
        devShell = unstable.mkShell {
          buildInputs = baseDevShell.buildInputs ++ [
            unstable.dotnet-sdk_8
          ];

          shellHook = baseDevShell.shellHook;
        };
      }
    );
}
