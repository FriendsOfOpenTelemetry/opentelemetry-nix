inputs:

final:
prev:

let
  mkOtelCollectorBuilderConfiguration = prev.callPackage ./build-support/mk-otel-collector-builder-configuration.nix { };
  buildOtelCollector = prev.callPackage ./build-support/build-otel-collector.nix { };
in {
  inherit mkOtelCollectorBuilderConfiguration buildOtelCollector;
}