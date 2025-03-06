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

      neovim.package = inputs'.izvim.packages.neovimMinimal;
    };
  };
}
