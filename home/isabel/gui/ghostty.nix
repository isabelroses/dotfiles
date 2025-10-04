{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.ghostty = {
    # FIXME: ghostty is broken on darwin
    package = if pkgs.stdenv.hostPlatform.isLinux then pkgs.ghostty else null;

    settings = {
      command = "/run/current-system/sw/bin/fish";

      theme = lib.mkForce "cuddlefish";

      background-opacity = 0.95;
      cursor-style = "bar";
      window-padding-x = "4,4";
      gtk-titlebar = false;

      window-save-state = "always";

      font-family = config.garden.style.fonts.name;
      font-size = 13;

      keybind = [
        "super+u=copy_url_to_clipboard"
      ];
    };
  };
}
