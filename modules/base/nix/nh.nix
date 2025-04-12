{ inputs', ... }:
{
  programs.nh = {
    enable = true;
    package = inputs'.tgirlpkgs.packages.nh;

    clean = {
      enable = false;
      dates = "weekly";
    };
  };
}
