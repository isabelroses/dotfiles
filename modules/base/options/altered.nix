{ lib, ... }:
let
  inherit (lib.modules) mkRemovedOptionModule;
in
{
  imports = [
    (mkRemovedOptionModule [
      "garden"
      "services"
      "vscode-server"
    ] "Unused")
  ];
}
