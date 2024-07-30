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
  description = "A development environment that combines all the other development environments.";

  inputs = {
    base_flake.url = "github:seventymx/game_theory_grpc_base_flake";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    playing_field.url = "github:seventymx/game_theory_grpc_playing_field";
    tit_for_tat.url = "github:seventymx/game_theory_grpc_tit_for_tat";
    friedman.url = "github:seventymx/game_theory_grpc_friedman";
    php_interface.url = "github:seventymx/game_theory_grpc_php_interface";
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        unstable = import inputs.nixpkgs { inherit system; };

        baseDevShell = inputs.base_flake.devShell.${system};

        allShells = [
          inputs.playing_field
          inputs.tit_for_tat
          inputs.friedman
          inputs.php_interface
        ];

        devShells = map (input: input.devShell.${system}) allShells;

        concatMap = f: list: unstable.lib.flatten (map f list);

        buildInputs = concatMap (shell: shell.buildInputs or [ ]) devShells;
      in
      {
        devShell = unstable.mkShell {
          buildInputs = baseDevShell.buildInputs ++ buildInputs;

          shellHook = baseDevShell.shellHook;
        };
      }
    );
}
