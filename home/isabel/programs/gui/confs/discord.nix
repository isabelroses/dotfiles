{
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  programs = osConfig.modules.programs;
  sys = osConfig.modules.system;
  acceptedTypes = ["laptop" "desktop" "hybrid"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes && programs.gui.enable && sys.video.enable) {
    home.packages = with pkgs; [
      ((discord.override {
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
