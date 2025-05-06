{ inputs', ... }:
{
  garden.system = {
    users = [ "robin" ];
  };

  home-manager.users.robin.garden = {
    programs = {
      notes.enable = true;

      hyprland.enable = true;

      zsh.enable = true;
      defaults.shell = "zsh";

      neovim.package = inputs'.ivy.packages.default;

      # programs
      rofi.enable = true;
      waybar.enable = true;
      chromium.enable = true;

      defaults.screenLocker = null;

      discord.enable = true;
    };
  };
}
