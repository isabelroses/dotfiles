{
  garden.system = {
    users = [ "robin" ];
  };

  home-manager.users.robin = {
    programs = {
      hyprland.enable = true;

      zsh.enable = true;
      defaults.shell = "zsh";

      # programs
      rofi.enable = true;
      waybar.enable = true;
      chromium.enable = true;

      discord.enable = true;
    };

    garden = {
      defaults.screenLocker = null;
    };
  };
}
