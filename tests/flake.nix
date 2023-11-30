{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    opentelemetry-nix = {
      url = "./..";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, opentelemetry-nix }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ opentelemetry-nix.overlays.default ];
      };
      pname = "debug-exporter-collector";
      version = "1.0.0";
      config = {
        exporters = [
          { gomod = "go.opentelemetry.io/collector/exporter/debugexporter v0.90.0"; }
        ];
      };
    in
    {
      packages.x86_64-linux = {
        debug-exporter-collector = pkgs.buildOtelCollector {
          inherit pname version config;
          vendorHash = "sha256-YcDubFUz+cAmsco7N0k94u6E6YrfcHUFxRm7erXV/VE=";
        };
        debug-exporter-config = pkgs.mkOtelCollectorBuilderConfiguration {
          inherit pname version config;
        };
        default = self.packages.x86_64-linux.debug-exporter-collector;
      };
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [ self.packages.x86_64-linux.debug-exporter-collector ];
      };
    };
}
