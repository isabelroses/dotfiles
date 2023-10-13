_: {
  modules.services = {
    vscode-server.enable = false;
    miniflux.enable = false;
    matrix.enable = true;
    mailserver.enable = true;
    gitea.enable = true;
    vaultwarden.enable = true;
    isabelroses-web.enable = true;
    nginx.enable = true;

    monitoring = {
      grafana.enable = true;
      prometheus.enable = true;
    };

    database = {
      mysql.enable = false;
      mongodb.enable = false;
      postgresql.enable = true;
    };
  };
}
