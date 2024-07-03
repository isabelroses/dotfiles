{ lib, config, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.garden.programs.gaming =
    let
      cfg = config.garden.programs.gaming;
    in
    {
      enable = mkEnableOption "Enable packages required for the device to be gaming-ready";

      emulation.enable = mkEnableOption "Enable programs required to emulate other platforms";

      minecraft.enable = mkEnableOption "Enable minecraft";

      mangohud.enable = mkEnableOption "Enable MangoHud" // {
        default = cfg.enable;
      };
    };

}
