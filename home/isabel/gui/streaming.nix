{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.garden.profiles.streaming.enable =
    lib.mkEnableOption "Enable streaming and broadcasting software";

  config = lib.mkIf config.garden.profiles.streaming.enable {
    garden.packages = {
      inherit (pkgs) chatterino7;
    };

    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-multi-rtmp
        obs-move-transition
      ];
    };
  };
}
