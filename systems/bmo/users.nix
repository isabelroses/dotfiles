{
  garden.system = {
    users = [ "robin" ];
  };

  home-manager.users.robin = {
    programs = {
      hyprland.enable = true;

      # programs
      firefox.enable = true;
      chromium.enable = true;

      discord.enable = true;
    };

    garden.programs.defaults = {
      shell = "zsh";
      bar = "quickshell";
      browser = "chromium";
      screenLocker = null;
    };
  };
}
