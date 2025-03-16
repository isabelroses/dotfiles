{ pkgs, config, ... }:
{
  # home-manager is so strange and needs these declared multiple times
  programs = {
    fish.enable = config.garden.meta.fish;
    zsh.enable = config.garden.meta.zsh;
  };

  garden.packages = {
    # GNU core utilities (rewritten in rust)
    # a good idea for usage on macOS too
    inherit (pkgs) uutils-coreutils-noprefix;
  };
}
