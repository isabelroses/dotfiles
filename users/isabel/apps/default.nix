{
  config,
  pkgs,
  lib,
  ...
}: let
  filterNixFiles = k: v: v == "regular" && k != "default.nix" && lib.hasSuffix ".nix" k;
  importNixFiles = path: filter:
    with lib;
      (lists.forEach (mapAttrsToList (name: _: path + ("/" + name))
          (filterAttrs filter (builtins.readDir path))))
      import;
in {
  imports = importNixFiles ../apps filterNixFiles;
}
