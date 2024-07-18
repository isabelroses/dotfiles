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
