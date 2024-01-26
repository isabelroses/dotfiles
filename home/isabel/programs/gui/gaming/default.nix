{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  inherit (osConfig.modules) programs;
in {
  imports = [./minecraft.nix];

  config = lib.mkIf programs.gaming.enable {
    home = {
      packages = with pkgs; [
        gamescope
        legendary-gl
        mono
        winetricks
        mangohud
        lutris
        #dolphin-emu # cool emulator
        #yuzu # switch emulator
        dotnet-runtime_6 # needed by terraria
      ];
    };
  };
}
