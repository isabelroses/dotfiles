{ pkgs, ... }:
{
  garden.wrappers.eza = {
    enable = true;
    package = pkgs.eza;
    flags = [
      "--icons auto"
      "--group"
      "--group-directories-first"
      "--header"
      "--no-permissions"
      "--octal-permissions"
    ];
  };
}
