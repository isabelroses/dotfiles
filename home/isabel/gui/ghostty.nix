{
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  programs.ghostty = {
    # FIXME: ghostty is broken on darwin
    package = if isLinux then pkgs.ghostty else null;

    settings = {
      command = "/run/current-system/sw/bin/fish";

      background-opacity = 0.95;
      cursor-style = "bar";
      window-padding-x = "4,4";
      gtk-titlebar = false;

      window-save-state = "always";

      font-family = config.garden.style.fonts.name;
      font-size = 13;

      # home-manager does this for us
      shell-integration = "none";
      shell-integration-features = "ssh-env";

      keybind = [
        "super+u=copy_url_to_clipboard"
      ];
    };
  };
}
