inputs:

final: prev:

let
  packages = import ./packages inputs final prev;
  lib = import ./lib.nix inputs final prev;
in
packages // lib
