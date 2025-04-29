{ inputs', ... }:
{
  garden.system = {
    mainUser = "robin";
    users = [ "robin" ];
  };

  home-manager.users.robin.garden = {
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

      zsh.enable = true;
      defaults.shell = "zsh";

      neovim.package = inputs'.ivy.packages.default;
    };
  };
}
