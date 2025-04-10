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
      git.signingKey = "7F2F6BD6997FCDF7";

      neovim.package = inputs'.izvim.packages.izvimMinimal;
    };
  };
}
