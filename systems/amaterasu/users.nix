{
  home-manager.users.isabel = {
    programs = {
      git.signing.key = "3E7C7A1B5DEDBB03";

      discord.enable = true;
      ghostty.enable = true;
      wezterm.enable = true;
      chromium.enable = true;
      fish.enable = true;
      fht-compositor.enable = true;
      quickshell.enable = true;
    };
  };
}
