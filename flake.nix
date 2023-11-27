{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/x86_64-linux";
  };

  outputs = inputs @ { self, nixpkgs, flake-parts, systems }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;
      flake = {
        overlays.default = import ./src/overlay.nix inputs;
      };
      perSystem = { self', config, pkgs, system, lib, ... }: {
        _module.args.pkgs = import self.inputs.nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
        };

        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.go ];
        };

        packages = lib.filterAttrs (n: v: lib.isDerivation v) (self.overlays.default null pkgs);

        apps = lib.mapAttrs (n: v: { type = "app"; program = v; }) self'.packages;
      };
    };
}
