{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.modules.style.gtk = {
    enable = mkEnableOption "GTK theming options";
    usePortal = mkEnableOption "native desktop portal use for filepickers";
  };
}
