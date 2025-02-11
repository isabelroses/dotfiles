_info: _final: prev:
let
  nixpkgsLib = import <nixpkgs/lib>;
in
nixpkgsLib.optionalAttrs (prev ? lib) {
  lib = prev.lib.extend (_: _: nixpkgsLib);
}
