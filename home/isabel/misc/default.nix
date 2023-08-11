{
  lib,
  config,
  osConfig,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
  sys = osConfig.modules.system;

  symlink = fileName: {recursive ? false}: {
    source = config.lib.file.mkOutOfStoreSymlink "${sys.flakePath}/home/${sys.username}/misc/${fileName}";
    inherit recursive;
  };
  pictures = "media/pictures";
in {
  config = mkIf (builtins.elem device.type acceptedTypes && sys.video.enable) {
    home.file = {
      "${pictures}/pfps" = symlink "pfps" {
        recursive = true;
      };
      "${pictures}/wallpapers" = symlink "wallpapers" {
        recursive = true;
      };
    };
  };
}
