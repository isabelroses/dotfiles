{
  home-manager.users.isabel = {
    garden.programs.defaults.shell = "fish";

    programs = {
      git.signing.key = "3E7C7A1B5DEDBB03";
      fish.enable = true;
    };
  };
}
