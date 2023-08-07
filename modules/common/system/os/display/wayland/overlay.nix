{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  video = config.modules.system.video;
  env = config.modules.usrEnv;
in {
  config = mkIf (video.enable && env.isWayland) {
    nixpkgs.overlays = with inputs; [
      nixpkgs-wayland.overlay
    ];
  };
}
