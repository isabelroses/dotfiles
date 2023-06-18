{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cloud = import ../../env.nix;
in {
  #systemd
  systemd.services = {
    tunnel = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "network-online.target" "systemd-resolved.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=${cloud.env}";
        Restart = "always";
        User = "${system.currentUser}";
        Group = "cloudflared";
      };
    };
  };
}
