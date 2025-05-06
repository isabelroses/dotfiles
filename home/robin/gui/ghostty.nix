{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.garden.programs.ghostty;
in
{
  programs.ghostty = mkIf cfg.enable {
    enable = true;

    # FIXME: ghostty is broken on darwin
    package = if pkgs.stdenv.hostPlatform.isLinux then cfg.package else null;

    settings = {
      command = "/etc/profiles/per-user/robin/bin/fish --login";

      theme = "catppuccin-mocha";
      background-opacity = 0.95;
      cursor-style = "bar";
      window-padding-x = "4,4";
      window-decoration = toString pkgs.stdenv.hostPlatform.isDarwin;
      gtk-titlebar = false;

      window-save-state = "always";

      font-family = config.garden.style.fonts.name;
      font-size = 13;
    };
  };
}
