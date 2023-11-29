inputs:

final:
prev:

{
  grafana-agent = (prev.callPackage ./grafana-agent { }) { };
  otel-collector-builder = prev.callPackage ./otel-collector-builder.nix { };
  # ToDo: use upstream https://github.com/NixOS/nixpkgs/pull/265436
  otel-desktop-viewer = prev.callPackage ./otel-desktop-viewer.nix { };
  tracetest = prev.callPackage ./tracetest.nix { };
}
