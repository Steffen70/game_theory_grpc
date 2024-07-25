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
