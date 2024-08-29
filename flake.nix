{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Zenn-cli
            nodejs

            # Nix tools
            nil
            nixpkgs-fmt
          ];

          shellHook = ''
            export PS1="\n[nix-shell:\w]$ "
          '';
        };

        # Use `nix fmt`
        formatter =
          treefmtEval.config.build.wrapper;

        # Use `nix flake check`
        checks = {
          formatting = treefmtEval.config.build.check self;
        };
      });
}
