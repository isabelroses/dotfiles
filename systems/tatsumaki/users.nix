{ inputs', ... }:
{
  home-manager.users.isabel.garden = {
    programs = {
      notes.enable = true;

      neovim = {
        enable = true;
        gui.enable = true;
      };

      discord.enable = true;
      git.signingKey = "3E7C7A1B5DEDBB03";
      fish.enable = true;

      neovim.package = inputs'.izvim.packages.default;
    };
  };
}
