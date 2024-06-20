{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf osConfig.modules.programs.gui.discord.enable {
    home.packages = mkIf pkgs.stdenv.isLinux [
      (
        (pkgs.discord.override {
          nss = pkgs.nss_latest;
          withOpenASAR = true;
          withVencord = true;
        }).overrideAttrs
        (old: {
          libPath = old.libPath + ":${pkgs.libglvnd}/lib";
          nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.makeWrapper ];

          postFixup = ''
            wrapProgram $out/opt/Discord/Discord \
              --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}}"
          '';
        })
      )
    ];

    xdg.configFile."discord/settings.json".text = builtins.toJSON { SKIP_HOST_UPDATE = true; };
  };
}
