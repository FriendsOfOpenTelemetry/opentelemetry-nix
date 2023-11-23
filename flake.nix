{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    lib = import ./lib.nix { inherit pkgs; };
  in {

    packages.${system} = {
      otel-collector-builder = pkgs.callPackage ./default.nix { otel-collector-builder = self.packages.${system}.otel-collector-builder; };
      otel-collector-custom = lib.buildOtelCollector {
        name = "otel-collector-debugexporter";
        version = "1.0.0-0.86.0";
        settings = {
          exporters = [
            { gomod = "go.opentelemetry.io/collector/exporter/debugexporter v0.86.0"; }
          ];
        };
        vendorHash = "sha256-ntLTJQkP+tiMK2VTlH9vfJzcOJGFfloRW1CIIW2iwUg=";
        builder = self.packages.${system}.otel-collector-builder;
      };
      default = self.packages.${system}.otel-collector-builder;
    };

  };
}
