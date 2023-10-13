{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
  cfg = config.modules.services;

  # stolen the functions https://github.com/NotAShelf/nyx/blob/614c3b0ee09b41a21bbd2395d1294bb55028657b/modules/common/options/system/services.nix

  # ifOneEnabled takes a parent option and 3 child options and checks if at least one of them is enabled
  # => ifOneEnabled config.modules.services "service1" "service2" "service3"
  ifOneEnabled = cfg: a: b: c: cfg.a || cfg.b || cfg.c;

  # mkEnableOption is the same as mkEnableOption but with the default value being equal to cfg.monitoring.enable
  mkEnableOption' = desc: mkEnableOption "${desc}" // {default = cfg.monitoring.enable;};
in {
  options.modules.services = {
    mailserver.enable = mkEnableOption "Enable the mailserver service";
    matrix.enable = mkEnableOption "Enable matrix server";
    miniflux.enable = mkEnableOption "Enable miniflux rss news aggreator service";
    gitea.enable = mkEnableOption "Enable the gitea service";
    cyberchef.enable = mkEnableOption "Enable the cyberchef website";
    vaultwarden.enable = mkEnableOption "Enable the vaultwarden service";
    photoprism.enable = mkEnableOption "Enable the photoprism service";
    vscode-server.enable = mkEnableOption "Enables remote ssh vscode server";
    isabelroses-web.enable = mkEnableOption "Enables my website";
    searxng.enable = mkEnableOption "Enables searxng search engine service";
    nginx.enable = mkEnableOption "Enables nginx webserver";
    cloudflared.enable = mkEnableOption "Enables cloudflared tunnels";
    wakapi.enable = mkEnableOption "Enables wakapit";

    jellyfin = {
      enable = mkEnableOption "Enables the jellyfin service";
      asDockerContainer = mkEnableOption "Enables the service as a docker container";
    };

    # monitoring tools
    monitoring = {
      enable = mkEnableOption "system monitoring services" // {default = ifOneEnabled cfg "grafana" "prometheus" "loki";};
      prometheus.enable = mkEnableOption' "Prometheus monitoring service";
      grafana.enable = mkEnableOption' "Grafana monitoring service";
      loki.enable = mkEnableOption' "Loki monitoring service";
    };

    # database backends
    database = {
      mysql.enable = mkEnableOption "MySQL database service";
      mongodb.enable = mkEnableOption "MongoDB service";
      postgresql.enable = mkEnableOption "Postgresql service";
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
