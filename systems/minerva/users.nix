{
  garden.system = {
    mainUser = "isabel";
  };

  home-manager.users.isabel.garden = {
    programs = {
      cli = {
        enable = false;
        modernShell.enable = false;
      };

      tui.enable = false;
      gui.enable = false;

      git.signingKey = "7F2F6BD6997FCDF7";
    };
  };
}
