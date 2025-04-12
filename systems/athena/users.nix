{ inputs', ... }:
{
  garden.system = {
    mainUser = "isabel";
  };

  home-manager.users.isabel.garden = {
    environment = {
      desktop = "cosmic";
    };

    programs = {
      cli = {
        enable = true;
        modernShell.enable = true;
      };
      tui.enable = true;
      gui.enable = true;

      git.signingKey = "7AFB9A49656E69F7";

      discord.enable = true;
      zathura.enable = true;
      wezterm.enable = false;
      ghostty.enable = true;
      chromium.enable = true;
      fish.enable = true;

      neovim.package = inputs'.izvim.packages.default;
    };
  };
}
