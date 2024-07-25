{
  description = "A development environment that combines all the other development environments.";

  inputs = {
    baseFlake.url = "path:./base_flake";
    nixpkgs.follows = "baseFlake/nixpkgs";
    flake-utils.follows = "baseFlake/flake-utils";

    playingField.url = "path:./playing_field";
    titForTat.url = "path:./tit_for_tat";
    friedman.url = "path:./friedman";
    phpInterface.url = "path:./php_interface";
  };

  outputs = { self, ... } @ inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        unstable = import inputs.nixpkgs {
          inherit system;
        };

        baseDevShell = inputs.baseFlake.outputs.devShell.${system};

        allShells = [inputs.playingField inputs.titForTat inputs.friedman inputs.phpInterface];

        devShells = map (input: input.outputs.devShell.${system}) allShells;

        concatMap = f: list: unstable.lib.flatten (map f list);

        buildInputs = concatMap (shell: shell.buildInputs or []) devShells;
      in
      {
        devShell = unstable.mkShell {
          buildInputs = baseDevShell.buildInputs ++ buildInputs;

          shellHook = baseDevShell.shellHook;
        };
      }
    );
}