{ inputs', ... }:
{
  home-manager.users.isabel.garden = {
    programs = {
      defaults.shell = "fish";

      git.signingKey = "3E7C7A1B5DEDBB03";
      fish.enable = true;

      neovim.package = inputs'.izvim.packages.default;
    };
  };
}
