{ inputs', ... }:
{
  garden.system = {
    mainUser = "robin";
    users = [ "robin" ];
  };

  home-manager.users.robin.garden = {
    programs = {
      notes.enable = true;

      zsh.enable = true;
      defaults.shell = "zsh";

      neovim.package = inputs'.ivy.packages.default;
    };
  };
}
