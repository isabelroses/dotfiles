{
  garden = {
    device.type = "laptop";

    system = {
      mainUser = "isabel";
    };

    environment = {
      desktop = "yabai";
      useHomeManager = true;
    };

    programs = {
      cli = {
        enable = true;
        modernShell.enable = true;
      };
      tui.enable = true;
      gui.enable = false;
      notes.enable = true;

      neovim.enable = true;
      ghostty.enable = true;
      wezterm.enable = true;
      discord.enable = false;
      git.signingKey = "3E7C7A1B5DEDBB03";
    };
  };
}
