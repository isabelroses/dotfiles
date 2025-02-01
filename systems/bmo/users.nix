{ inputs', ... }:
{
  garden.system = {
    mainUser = "robin";
    users = [ "robin" ];
  };

  home-manager.users.robin.garden = {
    environment = {
      desktop = "Hyprland";
    };

    programs = {
      cli = {
        enable = true;
        modernShell.enable = true;
      };
      tui.enable = true;
      gui.enable = true;
      notes.enable = true;

      defaults.shell = "fish";
      fish.enable = true;

      neovim.package = inputs'.ivy.packages.default;

      # programs
      ags.enable = false;
      rofi.enable = true;
      waybar.enable = true;
      chromium.enable = true;

      defaults.screenLocker = null;

      zathura.enable = true;
      discord.enable = true;
    };
  };
}
