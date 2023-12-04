{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
  cfg = config.modules.services;

  # mkEnableOption is the same as mkEnableOption but with the default value being equal to cfg.monitoring.enable
  mkEnableOption' = desc: mkEnableOption "${desc}" // {default = cfg.monitoring.enable;};
in {
  options.modules.services = {
    nextcloud.enable = mkEnableOption "Nextcloud service";
    matrix.enable = mkEnableOption "Enable matrix server";
    miniflux.enable = mkEnableOption "Enable miniflux rss news aggreator service";
    forgejo.enable = mkEnableOption "Enable the forgejo service";
    cyberchef.enable = mkEnableOption "Enable the cyberchef website";
    vaultwarden.enable = mkEnableOption "Enable the vaultwarden service";
    photoprism.enable = mkEnableOption "Enable the photoprism service";
    vscode-server.enable = mkEnableOption "Enables remote ssh vscode server";
    isabelroses-web.enable = mkEnableOption "Enables my website";
    searxng.enable = mkEnableOption "Enables searxng search engine service";
    nginx.enable = mkEnableOption "Enables nginx webserver";
    cloudflared.enable = mkEnableOption "Enables cloudflared tunnels";
    wakapi.enable = mkEnableOption "Enables wakapi";
    jellyfin.enable = mkEnableOption "Enables the jellyfin service";
    headscale.enable = mkEnableOption "Headscale service";

    mailserver = {
      enable = mkEnableOption "Enable the mailserver service";
      rspamd-web.enable = mkEnableOption "Enable rspamd web ui";
    };

    # monitoring tools
    monitoring = {
      enable = mkEnableOption "system monitoring services";
      prometheus.enable = mkEnableOption' "Prometheus monitoring service";
      grafana.enable = mkEnableOption' "Grafana monitoring service";
      loki.enable = mkEnableOption' "Loki monitoring service";
      uptime-kuma.enable = mkEnableOption' "Uptime Kuma monitoring service";
    };

    # database backends
    database = {
      influxdb.enable = mkEnableOption "Influxdb service";
      mysql.enable = mkEnableOption "MySQL database service";
      mongodb.enable = mkEnableOption "MongoDB service";
      postgresql.enable = mkEnableOption "Postgresql service";
      redis.enable = mkEnableOption "Redis service";
    };

    dns = {
      nextdns.enable = mkEnableOption "Enables the nextdns dns services";
      adguardhome.enable = mkEnableOption "Enables the adguardhome dns service";
    };

    smb = {
      enable = mkEnableOption "Enables smb shares";
      host.enable = mkEnableOption "Enables hosting of smb shares";

      # should smb shares be enabled as a recpient machine
      recive = {
        general = mkEnableOption "genral share";
        media = mkEnableOption "media share";
      };
    };
  };
}
