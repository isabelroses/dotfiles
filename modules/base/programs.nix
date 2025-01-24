{ config, ... }:
{
  # home-manager is so strange and needs these declared multiple times
  programs = {
    fish.enable = config.garden.meta.fish;
    zsh.enable = config.garden.meta.zsh;
  };
}
