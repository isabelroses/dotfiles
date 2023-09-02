{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  inherit (osConfig.modules.system) video;
  acceptedTypes = ["laptop" "desktop" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.usrEnv.programs.gui.enable && video.enable) {
    home.packages = with pkgs; [
      ((discord.override {
          nss = pkgs.nss_latest;
          withOpenASAR = true;
          withVencord = true;
        })
        .overrideAttrs (old: {
          libPath = old.libPath + ":${pkgs.libglvnd}/lib";
          nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.makeWrapper];

          postFixup = ''
            wrapProgram $out/opt/Discord/Discord --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}}"
          '';
        }))
    ];
  };
}
