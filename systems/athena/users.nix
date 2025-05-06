{ inputs', ... }:
{
  home-manager.users.isabel.garden = {
    programs = {
      git.signingKey = "7AFB9A49656E69F7";

      discord.enable = true;
      wezterm.enable = false;
      ghostty.enable = true;
      chromium.enable = true;
      fish.enable = true;

      neovim.package = inputs'.izvim.packages.default;
    };
  };
}
