{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    opentelemetry-nix = {
      url = "./..";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      opentelemetry-nix,
    }:
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
          { gomod = "go.opentelemetry.io/collector/exporter/debugexporter v0.121.0"; }
        ];
      };
    in
    {
      packages.x86_64-linux = {
        debug-otel-collector = pkgs.buildOtelCollector {
          inherit pname version config;
          vendorHash = "sha256-gUufO7NYvI8ewTZN5eepq0/tcfCCVexVJjjtTXZfpRA=";
        };
        debug-otel-config = pkgs.mkOtelCollectorBuilderConfiguration {
          inherit pname version config;
        };
        default = self.packages.x86_64-linux.debug-otel-collector;
      };
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [ self.packages.x86_64-linux.debug-otel-collector ];
      };
    };
}
