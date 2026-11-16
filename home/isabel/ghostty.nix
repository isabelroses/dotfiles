{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in
{
  programs.ghostty = {
    # FIXME: ghostty is broken on darwin
    package = if isLinux then pkgs.ghostty else null;

    settings = {
      command = "/run/current-system/sw/bin/fish";

      background-opacity = 0.90;
      cursor-style = "bar";
      window-padding-x = "4,4";

      # keep the text inset, but paint the padding with the edge cell's colour so
      # full-screen apps like nvim reach the window borders. Ghostty skips extending
      # for prompt rows and default-bg rows, so the shell keeps the plain padding
      window-padding-color = mkIf isLinux "extend";

      gtk-titlebar = false;

      window-save-state = "always";

      # let fontconfig handle this on linux
      font-family = mkIf isDarwin config.garden.style.fonts.name;
      font-size = mkIf isDarwin 13;

      # home-manager does this for us
      shell-integration = "none";
      shell-integration-features = "ssh-env";

      keybind = [
        "super+u=copy_url_to_clipboard"
      ];
    };
  };
}
