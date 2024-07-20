# FIXME: this just doesn't work on darwin??? Probably because of the way i made
# by custom builder operate
{ pkgs, ... }:
{
  programs.nh = {
    enable = true;
    clean = {
      enable = pkgs.stdenv.isDarwin;
      dates = "daily";
    };
  };
}
