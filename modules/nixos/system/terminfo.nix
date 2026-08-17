# put terminfo onto our servers so the ssh experience is better
{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.modules.mkIf config.services.openssh.enable {
    garden.packages = {
      inherit (pkgs.ghostty) terminfo;
    };
  };
}
