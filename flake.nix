{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ self.overlays.default ];
    };
    overlay = import ./src/overlay.nix inputs;
  in {

    overlays.default = overlay;

    devShells.${system}.default = pkgs.mkShell {
      packages = [ pkgs.go ];
    };

    packages.${system} = pkgs.lib.filterAttrs (n: v: pkgs.lib.isDerivation v) (overlay null pkgs);
  };
}
