{
  garden.system = {
    mainUser = "isabel";
  };

  home-manager.users.isabel.garden = {
    environment = {
      desktop = "cosmic";
    };

    programs = {
      cli = {
        enable = true;
        modernShell.enable = true;
      };
      tui.enable = true;
      gui.enable = true;

      git.signingKey = "7F2F6BD6997FCDF7";

      discord.enable = true;
      zathura.enable = true;
      wezterm.enable = true;
      ghostty.enable = true;
      chromium.enable = true;
      fish.enable = true;
    };
  };
}
