{ lib, config, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  imports = [
    ./gamemode.nix # cool scripts, and programs to improve gaming performance
    ./steam.nix # steam, the gaming platform
  ];

  options.modules.programs.gaming =
    let
      cfg = config.modules.programs.gaming;
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
