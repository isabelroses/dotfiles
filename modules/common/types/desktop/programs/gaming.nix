{lib, ...}: let
  inherit (lib) mkDefault;
in {
  config.modules.programs.gaming = {
    enable = mkDefault true;
    minecraft.enable = mkDefault true;
  };
}
