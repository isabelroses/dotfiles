{
  lib,
  config,
  osConfig,
  ...
}: let
  inherit (lib) mkIf isModernShell;
in {
  config = mkIf (isModernShell osConfig) {
    programs.atuin = {
      enable = true;

      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
      enableNushellIntegration = config.programs.nushell.enable;

      flags = ["--disable-up-arrow"];
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
  };
}
