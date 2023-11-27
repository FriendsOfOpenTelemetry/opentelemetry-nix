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
    in
    {
      packages.x86_64-linux = {
        debug = pkgs.buildOtelCollector {
          pname = "otel-collector-debugexporter";
          version = "1.0.0-0.86.0";
          config = {
            exporters = [
              { gomod = "go.opentelemetry.io/collector/exporter/debugexporter v0.86.0"; }
            ];
          };
          vendorHash = "sha256-EEPIm3mQDGa418vhUtO5NlzoF7b5ggbTI8zcxbjttIg=";
        };
        default = self.packages.x86_64-linux.debug;
      };
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [ self.packages.x86_64-linux.debug ];
      };
    };
}