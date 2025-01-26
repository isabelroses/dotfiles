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

      kitty.enable = true;
      wezterm.enable = true;
      zathura.enable = true;
      rofi.enable = true;
      fish.enable = true;

      neovim.package = inputs'.ivy.packages.default;
    };
  };
}
