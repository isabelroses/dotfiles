{
  pkgs,
  lib,
  config,
  osConfig,
  defaults,
  ...
}: let
  inherit (osConfig.modules) system;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && (lib.isWayland osConfig) && osConfig.modules.programs.gui.enable && defaults.bar == "ags") {
    home = {
      packages = with pkgs; [
        socat
        sassc
        networkmanagerapplet
        inotify-tools
        swww
      ];
    };
    xdg.configFile = let
      symlink = fileName: {recursive ? false}: {
        source = config.lib.file.mkOutOfStoreSymlink "${system.flakePath}/${fileName}";
        inherit recursive;
      };
    in {
      "ags" = symlink "home/${system.mainUser}/programs/gui/confs/bars/ags/config" {
        recursive = true;
      };
    };
  };
}
