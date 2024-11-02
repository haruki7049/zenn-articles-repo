{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, ... }:
        let
          nodeEnv = pkgs.callPackage "${inputs.nixpkgs}/pkgs/development/node-packages/node-env.nix" {
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
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };
          devShells.default = pkgs.mkShell {
            packages = [
              # Zenn-cli
              pkgs.nodejs

              # Nix tools
              pkgs.nil
            ];

            shellHook = ''
              export PS1="\n[nix-shell:\w]$ "
            '';
          };
        };
    };
}
