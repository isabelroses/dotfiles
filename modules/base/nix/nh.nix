{ inputs', ... }:
{
  programs.nh = {
    enable = false;
    package = inputs'.tgirlpkgs.packages.nh;

    clean = {
      enable = false;
      dates = "weekly";
    };
  };
}
