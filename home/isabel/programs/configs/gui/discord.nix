{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  inherit (lib) mkIf isWayland ldTernary;

  fmt = pkgs.formats.json {};
in {
  config = mkIf osConfig.modules.programs.gui.discord.enable {
    home.packages =
      ldTernary pkgs
      [
        ((pkgs.discord.override {
            nss = pkgs.nss_latest;
            withOpenASAR = true;
            withVencord = true;
            withTTS = false;
          })
          .overrideAttrs (old: {
            libPath = old.libPath + ":${pkgs.libglvnd}/lib";
            nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.makeWrapper];

            postFixup = mkIf (isWayland osConfig) ''
              wrapProgram $out/opt/Discord/Discord --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}}"
            '';
          }))
      ]
      [
        (pkgs.discord.override {
          withOpenASAR = true;
          withVencord = true;
        })
      ];

    xdg.configFile."discord/settings.json".source = fmt.generate "discord.json" {
      SKIP_HOST_UPDATE = true;
    };
  };
}
