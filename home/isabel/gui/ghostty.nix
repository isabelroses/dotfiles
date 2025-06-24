{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkForce;

  cfg = config.garden.programs.ghostty;
in
{
  programs.ghostty = {
    inherit (cfg) enable;

    # FIXME: ghostty is broken on darwin
    package = if pkgs.stdenv.hostPlatform.isLinux then cfg.package else null;

    settings = {
      command = "/etc/profiles/per-user/isabel/bin/fish --login";

      # theme = mkForce "cuddlefish";

      background-opacity = 0.95;
      cursor-style = "bar";
      window-padding-x = "4,4";
      window-decoration = toString pkgs.stdenv.hostPlatform.isDarwin;
      gtk-titlebar = false;

      window-save-state = "always";

      font-family = config.garden.style.fonts.name;
      font-family-bold = config.garden.style.fonts.bold;
      font-family-italic = config.garden.style.fonts.italic;
      font-family-bold-italic = config.garden.style.fonts.bold-italic;
      font-size = 13;
    };
  };
}
