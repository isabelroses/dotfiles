{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;

  cfg = config.garden.programs.ghostty;
in
{
  programs.ghostty = mkIf cfg.enable {
    enable = true;

    # FIXME: ghostty is broken on darwin
    package = if pkgs.stdenv.hostPlatform.isLinux then cfg.package else null;

    settings = {
      command = "/etc/profiles/per-user/isabel/bin/fish --login";

      theme = mkForce "evergarden";
      background-opacity = 0.95;
      cursor-style = "bar";
      window-padding-x = "4,4";
      window-decoration = toString pkgs.stdenv.hostPlatform.isDarwin;
      gtk-titlebar = false;

      window-save-state = "always";

      font-family = osConfig.garden.style.font.name;
      font-family-bold = osConfig.garden.style.font.bold;
      font-family-italic = osConfig.garden.style.font.italic;
      font-family-bold-italic = osConfig.garden.style.font.bold-italic;
      font-size = 13;
    };
  };
}
