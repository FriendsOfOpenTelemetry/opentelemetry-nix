inputs:

final:
prev:

{
  otel-collector-builder = prev.callPackage ./otel-collector-builder.nix { };
  # Remove when merged: https://github.com/NixOS/nixpkgs/pull/275406
  tracetest = prev.callPackage ./tracetest.nix { };
}
