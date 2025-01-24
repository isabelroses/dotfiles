{
  # This is enabled by default, but we don't want it
  # NOTE: this will break some programs that call `man` for you like `nix-collect-garbage`
  programs.man.enable = false;
}
