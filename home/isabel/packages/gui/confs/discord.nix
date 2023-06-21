{
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    home.packages = with pkgs; [
      ((discord.override {
          withOpenASAR = true;
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
