{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) isx86Linux;
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    # pipewire is newer and just better
    services.pipewire = {
      enable = true;

      audio.enable = true;
      pulse.enable = true;
      jack.enable = true;

      alsa = {
        enable = true;
        support32Bit = isx86Linux pkgs;
      };
    };

    systemd.user.services = {
      pipewire.wantedBy = [ "default.target" ];
      pipewire-pulse.wantedBy = [ "default.target" ];
    };
  };
}
