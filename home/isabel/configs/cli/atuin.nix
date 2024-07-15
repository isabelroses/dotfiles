{
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;
in
{
  programs.atuin = mkIf (isModernShell osConfig) {
    enable = true;

    enableBashIntegration = config.programs.bash.enable;
    enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableNushellIntegration = config.programs.nushell.enable;

    flags = [ "--disable-up-arrow" ];
    settings = {
      dialect = "uk";
      show_preview = true;
      inline_height = 30;
      style = "compact";
      update_check = false;
      sync_address = "https://atuin.isabelroses.com";
      sync_frequency = "5m";
    };
  };
}
