{
  garden.system = {
    mainUser = "isabel";
  };

  home-manager.users.isabel.garden = {
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

      defaults.shell = "nushell";

      git.signingKey = "3E7C7A1B5DEDBB03";
      fish.enable = true;
      nushell.enable = true;
    };
  };
}
