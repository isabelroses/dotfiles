{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
in
{
  config = mkIf config.garden.profiles.gaming.enable {
    garden.packages = { inherit (pkgs) prismlauncher; };

    programs = {
      steam = {
        enable = true;

        # proton-ge carries fixes (media codecs, game specific patches) that
        # valve's proton lacks, which a lot of unity titles like raft benefit from.
        # select it per game under properties -> compatibility
        extraCompatPackages = [ pkgs.proton-ge-bin ];

        gamescopeSession.enable = true;
      };

      gamescope = {
        enable = true;
        capSysNice = true;
      };

      gamemode = {
        enable = true;
        enableRenice = true;

        settings.general = {
          softrealtime = "auto";
          renice = 15;
        };
      };
    };
  };
}
