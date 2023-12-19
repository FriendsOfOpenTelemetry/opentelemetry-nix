inputs:

final:
prev:

{
  otel-collector-builder = prev.callPackage ./otel-collector-builder.nix { };
  tracetest = prev.callPackage ./tracetest.nix { };
}
