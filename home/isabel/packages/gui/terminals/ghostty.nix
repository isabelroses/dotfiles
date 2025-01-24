{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;

  cfg = config.garden.programs.ghostty;
in
{
  programs.ghostty = mkIf cfg.enable {
    enable = true;

    # FIXME: ghostty is broken on darwin
    package = if pkgs.stdenv.hostPlatform.isLinux then cfg.package else pkgs.bashInteractive;

    enableBashIntegration = config.programs.bash.enable;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;

    # produces an error, besides it's not needed since catppuccin/nix handles this for us
    installBatSyntax = false;

    settings = {
      command = "/etc/profiles/per-user/isabel/bin/fish --login";

      theme = "catppuccin-mocha";
      background-opacity = 0.95;
      cursor-style = "bar";
      window-padding-x = "4,4";
      window-decoration = toString pkgs.stdenv.hostPlatform.isDarwin;
      gtk-titlebar = false;

      window-save-state = "always";

      font-family = osConfig.garden.style.font.name;
      font-size = 13;
    };
  };
}
