{
  home-manager.users.isabel = {
    programs = {
      discord.enable = true;
      ghostty.enable = true;
      chromium.enable = true;
      obs-studio.enable = true;
      fish.enable = true;
      hyprland.enable = true;
      quickshell.enable = true;
    };

    garden.profiles.media = {
      creation.enable = true;
      streaming.enable = true;
    };
  };
}
