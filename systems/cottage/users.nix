{
  garden.system = {
    users = [ "robin" ];
  };

  home-manager.users.robin = {
    programs = {
      hyprland.enable = true;

      rofi.enable = true;
      fish.enable = true;
    };

    garden.style.fonts.name = "Maple Mono NF";
  };
}
