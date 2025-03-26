{
  self,
  config,
  inputs',
  ...
}:
let
  inherit (self.lib.validators) hasProfile;
in
{
  programs.nh = {
    enable = !hasProfile config [ "server" ];
    package = inputs'.tgirlpkgs.packages.nh;

    clean = {
      enable = false;
      dates = "weekly";
    };
  };
}
