{ config, lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.modules.programs.gaming =
    let
      cfg = config.modules.programs.gaming;
    in
    {
      enable = mkEnableOption "Enable packages required for the device to be gaming-ready";
      emulation.enable = mkEnableOption "Enable programs required to emulate other platforms";

      steam.enable = mkEnableOption "Enable Steam" // {
        default = cfg.enable;
      };
      minecraft.enable = mkEnableOption "Enable minecraft";

      gamescope.enable = mkEnableOption "Gamescope compositing manager" // {
        default = cfg.enable;
      };
      mangohud.enable = mkEnableOption "Enable MangoHud" // {
        default = cfg.enable;
      };
    };
}
