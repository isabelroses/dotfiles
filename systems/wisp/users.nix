{
  garden.system = {
    mainUser = "robin";
    users = [ "robin" ];
  };

  home-manager.users.robin = {
    garden.programs.defaults.shell = "zsh";

    programs = {
      zsh.enable = true;
    };
  };
}
