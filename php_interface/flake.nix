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
  description = "A development environment for working with PHP and gRPC.";

  inputs = {
    base_flake.url = "git+file:///workspace/game_theory_grpc/base_flake";
    nixpkgs.follows = "base_flake/nixpkgs";
    flake-utils.follows = "base_flake/flake-utils";
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        unstable = import inputs.nixpkgs { inherit system; };

        baseDevShell = inputs.base_flake.outputs.devShell.${system};

        # Create a custom PHP build with the grpc extension and custom configuration
        myPhp = unstable.php.withExtensions (exts: [
          unstable.php.extensions.grpc
          unstable.php.extensions.protobuf
        ]);
      in
      {
        devShell = unstable.mkShell {
          buildInputs = baseDevShell.buildInputs ++ [
            unstable.protobuf
            unstable.grpc # C based gRPC
            myPhp
            unstable.php83Packages.composer # PHP dependency manager
          ];

          shellHook = baseDevShell.shellHook;
        };
      }
    );
}
