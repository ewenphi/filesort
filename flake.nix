{
  description = "simple filesorter, which goal is for me to learn go.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mydevenvs.url = "github:yvaniak/mydevenvs";
    mydevenvs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.mydevenvs.inputs.devenv.flakeModule
        inputs.mydevenvs.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          self',
          pkgs,
          config,
          lib,
          ...
        }:
        {
          packages.filesort = pkgs.callPackage ./default.nix { };
          packages.default = self'.packages.filesort;

          devenv.shells.default = {
            languages.go.enable = lib.mkForce false;
            mydevenvs = {
              go.enable = true;
              nix = {
                enable = true;
                check.enable = true;
                check.package = config.packages.default;
                flake.enable = true;
              };
              tools.just = {
                enable = true;
                pre-commit.enable = true;
                check.enable = true;
              };
            };

          };
        };
      flake = {
      };
    };
}
