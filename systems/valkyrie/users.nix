{
  home-manager.users.isabel = {
    garden.programs.defaults.shell = "fish";

    programs = {
      fish.enable = true;
    };
  };
}
