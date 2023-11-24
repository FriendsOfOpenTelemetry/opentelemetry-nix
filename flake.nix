{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    overlay = import ./src/overlay.nix inputs;
  in {

    overlays.default = overlay;

    # packages.${system} = {
    #   otel-collector-custom = lib.buildOtelCollector {
    #     name = "otel-collector-debugexporter";
    #     version = "1.0.0-0.86.0";
    #     settings = {
    #       exporters = [
    #         { gomod = "go.opentelemetry.io/collector/exporter/debugexporter v0.86.0"; }
    #       ];
    #     };
    #     vendorHash = "sha256-ntLTJQkP+tiMK2VTlH9vfJzcOJGFfloRW1CIIW2iwUg=";
    #     builder = pkgs.opentelemetry.otel-collector-builder;
    #   };
    #   default = self.packages.${system}.otel-collector-custom;
    # };

    packages.${system} = (pkgs.lib.filterAttrs (k: v: pkgs.lib.isDerivation v) (overlay null pkgs));
  };
}
