{
  config,
  lib,
  inputs,
  ...
}: let
  video = config.modules.system.video;
  env = config.modules.usrEnv;
in {
  config = lib.mkIf (video.enable && env.isWayland) {
    nixpkgs.overlays = with inputs; [
      nixpkgs-wayland.overlay
    ];
  };
}
