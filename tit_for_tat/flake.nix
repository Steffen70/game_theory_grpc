{
  description = "A development environment for working with Golang and gRPC.";

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
            unstable.protobuf
            unstable.go
            unstable.delve # Go debugging
            unstable.protoc-gen-go # Go protoc plugin
            unstable.protoc-gen-go-grpc # Go gRPC plugin
          ];

          shellHook = baseDevShell.shellHook;
        };
      }
    );
}
