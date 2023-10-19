_: {
  modules.services = {
    vscode-server.enable = false;
    miniflux.enable = false;
    matrix.enable = true;
    forgejo.enable = true;
    vaultwarden.enable = true;
    isabelroses-web.enable = true;
    nginx.enable = true;

    mailserver = {
      enable = true;
      rspamd-web.enable = false;
    };

    monitoring = {
      grafana.enable = true;
      prometheus.enable = true;
    };

    database = {
      mysql.enable = false;
      mongodb.enable = false;
      postgresql.enable = true;
      redis.enable = true;
    };
  };
}
