{lib, ...}: let
  inherit (lib) mkDefault;
in {
  options.modules.programs.gaming = {
    enable = mkDefault true;
    minecraft.enable = mkDefault true;
  };
}
