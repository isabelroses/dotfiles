{ lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  options.modules.style.gtk = {
    enable = mkEnableOption "GTK theming options";
    usePortal = mkEnableOption "native desktop portal use for filepickers";

    font = {
      name = mkOption {
        type = types.str;
        description = "The name of the font that will be used for GTK applications";
        default = "CommitMono";
      };

      size = mkOption {
        type = types.int;
        description = "The size of the font";
        default = 14;
      };
    };
  };
}
