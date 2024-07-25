{
  description = "A development environment for working with dotnet 8 and PowerShell.";

  inputs = {
    baseFlake.url = "path:./base_flake";
    nixpkgs.url = "baseFlake/nixpkgs/";
    flake-utils.url = "baseFlake/flake-utils";
  };

  outputs = { self, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        unstable = import inputs.nixpkgs {
          inherit system;
        };

        baseFlake = import inputs.baseFlake {
            inherit system;
        };

        baseDevShell = baseFlake.devShell;
      in
      {
        devShell = unstable.mkShell {
          buildInputs = baseDevShell.buildInputs ++ [
            unstable.dotnet-sdk_8
          ];

          shell = baseDevShell.shell;

          env = baseDevShell.env // {
            PLAYING_FIELD_PORT = "5001";
          };
        };
      }
    );
}
