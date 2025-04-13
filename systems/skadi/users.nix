{ inputs', ... }:
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
        enable = false;
        modernShell.enable = false;
      };

      tui.enable = false;
      gui.enable = false;

      git.enable = true;
      git.signingKey = "3E7C7A1B5DEDBB03";

      neovim.package = inputs'.izvim.packages.izvimMinimal;
    };
  };
}
