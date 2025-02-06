{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isModernShell;
in
{
  programs.eza = mkIf (isModernShell config) {
    enable = true;
    icons = "auto";

    enableBashIntegration = config.programs.bash.enable;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;
    # enableNushellIntegration = config.programs.nushell.enable;

    extraOptions = [
      "--group"
      "--group-directories-first"
      "--no-permissions"
      "--octal-permissions"
    ];
  };
}
