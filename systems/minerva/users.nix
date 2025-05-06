{ inputs', ... }:
{
  home-manager.users.isabel.garden = {
    programs = {
      git.signingKey = "7F2F6BD6997FCDF7";

      neovim.package = inputs'.izvim.packages.izvimMinimal;
    };
  };
}
