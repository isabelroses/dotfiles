{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (osConfig.garden) programs;
in
{
  imports = [ ./minecraft.nix ];

  config = lib.modules.mkIf programs.gaming.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs)
        gamescope
        legendary-gl
        mono
        winetricks
        mangohud
        lutris
        #dolphin-emu # cool emulator
        #yuzu # switch emulator
        # dotnet-runtime_6 # needed by terraria
        ;
    };
  };
}
