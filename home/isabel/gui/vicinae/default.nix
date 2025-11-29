{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;

  mkMyVicinaeExt = pkgs.callPackage ./extension.nix { };
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    programs.vicinae = {
      enable = true;
      systemd.enable = true;

      settings = {
        window.opacity = 1;
      };

      extensions = map mkMyVicinaeExt [
        {
          extName = "nix";
          npmDepsHash = "sha256-Zx+QPVWWppz6mvQKyu4c6ND8E4TeeK12assE2khE/sA=";
        }
        {
          extName = "wifi-commander";
          npmDepsHash = "sha256-ufVZm0mpRPAgWRXP+h6yNM7cEfM/tdcc0FUBmZiBvBA=";
        }
        {
          extName = "bluetooth";
          npmDepsHash = "sha256-cpyuJTc3a7oLibKUY2EhD33w8/35frfwIaGFKFezvts=";
        }
        {
          extName = "mullvad";
          npmDepsHash = "sha256-WbnZtsTUMDHh2BojAjHUrca8aBw+OGXMMgX79Ek8wQ0=";
        }
      ];
    };
  };
}
