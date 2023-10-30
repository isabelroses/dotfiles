{lib, ...}: let
  inherit (lib) mkDefault;
in {
  config.modules.programs.gaming = {
    enable = mkDefault false;
    emulation.enable = mkDefault false;
    minecraft.enable = mkDefault false;
  };
}
