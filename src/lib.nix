inputs:

final:
prev:

let
  buildOtelCollector = prev.callPackage ./build-support/build-otel-collector.nix { };
in {
  inherit buildOtelCollector;
}