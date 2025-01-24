{
  garden.system = {
    mainUser = "isabel";
  };

  home-manager.users.isabel.garden = {
    programs = {
      cli = {
        enable = true;
        modernShell.enable = true;
      };
      tui.enable = true;
      gui.enable = false;

      git.signingKey = "08A97B9A107A1798";
      fish.enable = true;
    };
  };
}
