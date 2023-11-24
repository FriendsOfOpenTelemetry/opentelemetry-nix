inputs:

final:
prev:

let
  otel-collector-builder = prev.callPackage ./otel-collector-builder.nix { };
  otel-desktop-viewer = prev.callPackage ./otel-desktop-viewer.nix { };
in {
  inherit otel-collector-builder otel-desktop-viewer;
  default = otel-collector-builder;
}