{ inputs', ... }:
{
  home-manager.users.isabel.garden = {
    programs = {
      git.enable = true;
      git.signingKey = "3E7C7A1B5DEDBB03";

      neovim.package = inputs'.izvim.packages.izvimMinimal;
    };
  };
}
