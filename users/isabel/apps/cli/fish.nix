{
  ...
}: {
  xdg.configFile."fish" = {
    source = ../config/fish;
  };
  programs.fish = {
    enable = true;
  };
}
