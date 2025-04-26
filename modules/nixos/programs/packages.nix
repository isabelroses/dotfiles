{
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (self.lib.validators) hasProfile;
in
{
  # packages that should be on all deviecs
  garden.packages = {
    inherit (pkgs)
      curl
      wget
      pciutils
      lshw
      ;
  };

  # like `thefuck`, but in rust and actually maintained
  programs.pay-respects.enable = hasProfile config [ "graphical" ];
}
