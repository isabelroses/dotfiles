{
  pkgs,
  lib,
  config,
  osConfig,
  defaults,
  ...
}: let
  inherit (lib) mkIf;
  device = osConfig.modules.device;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
  programs = osConfig.modules.programs;
  sys = osConfig.modules.system;
in {
  config = mkIf (builtins.elem device.type acceptedTypes && programs.gui.enable && sys.video.enable && defaults.bar == "ags") {
    home = {
      packages = with pkgs; [
        nur.repos.bella.ags
        socat
        sassc
        networkmanagerapplet
        swww
      ];
    };
    xdg.configFile = let
      symlink = fileName: {recursive ? false}: {
        source = config.lib.file.mkOutOfStoreSymlink "${sys.flakePath}/${fileName}";
        inherit recursive;
      };
    in {
      "ags" = symlink "home/${sys.mainUser}/programs/gui/confs/bars/ags/config" {
        recursive = true;
      };
    };
  };
}
