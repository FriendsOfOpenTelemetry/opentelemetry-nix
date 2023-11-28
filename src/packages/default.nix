inputs:

final:
prev:

{
  grafana-agent = (prev.callPackage ./grafana-agent { }) { };
  otel-collector-builder = prev.callPackage ./otel-collector-builder.nix { };
  otel-desktop-viewer = prev.callPackage ./otel-desktop-viewer.nix { };
  tracetest = prev.callPackage ./tracetest.nix { };
}
