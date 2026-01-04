{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf genAttrs mkForce;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.transmission;
  inherit (config.garden.services) arr;
in
{
  options.garden.services.transmission = mkServiceOption "transmission" {
    port = 3019;
    host = "0.0.0.0";
  };

  config = mkIf config.garden.services.transmission.enable {
    # i'm replacing this with systemd tempfiles
    system.activationScripts.transmission-daemon = mkForce "";

    systemd.tmpfiles.settings."media-downloads-config" =
      genAttrs
        [
          "${config.services.transmission.home}"
          "${config.services.transmission.home}/.config"
          "${config.services.transmission.home}/.config/transmission-daemon"
        ]
        (_: {
          d = {
            mode = "0750";
            user = "transmission";
            group = "media";
          };
        });

    services.transmission = {
      enable = true;
      group = "media";

      openFirewall = true;
      home = "/srv/storage/transmission";

      settings = {
        download-dir = "${arr.mediaDir}/downloads";
        incomplete-dir-enabled = true;
        incomplete-dir = "${arr.mediaDir}/downloads/incomplete";
        watch-dir-enabled = true;
        watch-dir = "${arr.mediaDir}/downloads/watch";

        rpc-port = cfg.port;
        rpc-bind-address = cfg.host;
        rpc-authentication-required = false;

        rpc-whitelist-enabled = true;
        rpc-whitelist = lib.concatStringsSep "," [
          "127.0.0.1"
          "::1"
          "192.168.1.*"
        ];

        blocklist-enabled = true;
        blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";

        anti-brute-force-enabled = true;
        anti-brute-force-threshold = 10;

        encryption = 1;
        port-forwarding-enabled = false;

        utp-enabled = false;
        umask = "002";
        peer-limit-global = 500;
        cache-size-mb = 256;
        download-queue-enabled = true;
        download-queue-size = 20;
        speed-limit-up = 500;
        speed-limit-up-enabled = true;
        message-level = 4;
      };
    };
  };
}
