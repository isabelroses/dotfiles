{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkService;

  cfg = config.garden.services.loki;
  dir = config.services.loki.dataDir;
in
{
  imports = [
    (mkService "loki" { port = 3100; })
  ];

  config = mkIf cfg.enable {
    services.loki = {
      enable = true;

      configuration = {
        auth_enabled = false;
        analytics.reporting_enabled = false;

        server = {
          http_listen_address = cfg.host;
          http_listen_port = cfg.port;
          grpc_listen_address = "127.0.0.1";
        };

        common = {
          instance_addr = "127.0.0.1";
          path_prefix = dir;
          replication_factor = 1;
          ring.kvstore.store = "inmemory";
          storage.filesystem = {
            chunks_directory = "${dir}/chunks";
            rules_directory = "${dir}/rules";
          };
        };

        schema_config.configs = [
          {
            from = "2026-11-23";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];

        limits_config.retention_period = "30d";
        compactor = {
          working_directory = "${dir}/compactor";
          retention_enabled = true;
          delete_request_store = "filesystem";
        };
      };
    };
  };
}
