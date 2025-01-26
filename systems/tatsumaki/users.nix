{
  garden.system = {
    mainUser = "isabel";
  };

  users.isabel.garden = {
    environment = {
      desktop = null;
    };

    programs = {
      cli = {
        enable = true;
        modernShell.enable = true;
      };
      tui.enable = true;
      gui.enable = false;
      notes.enable = true;

      neovim = {
        enable = true;
        gui.enable = true;
      };

      ghostty.enable = true;
      wezterm.enable = false;
      discord.enable = false;
      git.signingKey = "3E7C7A1B5DEDBB03";
      fish.enable = true;
    };
  };
}
