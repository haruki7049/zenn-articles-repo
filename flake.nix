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
        nodeEnv = pkgs.callPackage "${nixpkgs}/pkgs/development/node-packages/node-env.nix" {
          inherit (pkgs)
            stdenv
            lib
            python2
            runCommand
            writeTextFile
            writeShellScript
            ;
          nodejs = pkgs.nodejs_20;
          libtool = null;
        };
        zenn-cli = nodeEnv.buildNodePackage rec {
          name = "zenn";
          packageName = "zenn-cli";
          version = "0.1.155";
          src = pkgs.fetchurl {
            url = "https://registry.npmjs.com/zenn-cli/-/zenn-cli-${version}.tgz";
            hash = "sha256-b3YTRoSA3mRq3njVcWn+vlvjSS/98rWWIOLNlstTREg=";
          };

          production = true;
          bypassCache = true;
          reconstructLock = true;
        };
      in
      {
        packages = {
          inherit zenn-cli;
          default = zenn-cli;
        };

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
