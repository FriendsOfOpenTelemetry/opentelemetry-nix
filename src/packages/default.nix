inputs:

final: prev:

{
  # Remove when merged: https://github.com/NixOS/nixpkgs/pull/275406
  tracetest = prev.callPackage ./tracetest { };
  tracepusher = prev.callPackage ./tracepusher { };
  har-to-otel = prev.callPackage ./har-to-otel { };
}
