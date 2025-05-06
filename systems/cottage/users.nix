{ inputs', ... }:
{
  garden.system = {
    users = [ "robin" ];
  };

  home-manager.users.robin.garden = {
    programs = {
      hyprland.enable = true;

      rofi.enable = true;
      fish.enable = true;

      neovim.package = inputs'.ivy.packages.default;
    };

    style.fonts.name = "Maple Mono NF";
  };
}
