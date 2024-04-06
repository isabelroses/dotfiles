{config, ...}: {
  config = {
    programs.yazi = {
      enable = true;

      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
      enableNushellIntegration = config.programs.nushell.enable;
    };

    xdg.configFile."yazi/theme.toml".text = builtins.replaceStrings ["~/.config/yazi/Catppuccin-mocha.tmTheme"] ["~/.config/bat/themes/Catppuccin Mocha.tmTheme"] (
      builtins.readFile
      (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/yazi/main/themes/mocha.toml";
        sha256 = "0pk4v3bqrx6safsxclz5fqns2fxwwllgdlfx8gqh9svi3k6hg71j";
      })
    );
  };
}
