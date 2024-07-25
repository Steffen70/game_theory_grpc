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
