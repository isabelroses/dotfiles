{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  sys = config.modules.system;
in {
  config = mkIf sys.services.monitoring.loki.enable {
    # https://gist.github.com/rickhull/895b0cb38fdd537c1078a858cf15d63e
    services.loki = {
      enable = true;
      dataDir = "/srv/storage/loki";

      configuration = {
        server.http_listen_port = 3030;
        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {
                store = "inmemory";
              };
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
          max_transfer_retries = 0;
        };

        schema_config = {
          configs = [
            {
              from = "2022-06-06";
              store = "boltdb-shipper";
              object_store = "filesystem";
              schema = "v11";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          boltdb_shipper = {
            active_index_directory = "/srv/storage/loki/boltdb-shipper-active";
            cache_location = "/srv/storage/loki/boltdb-shipper-cache";
            cache_ttl = "24h";
            shared_store = "filesystem";
          };

          filesystem = {
            directory = "/srv/storage/loki/chunks";
          };
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };

        chunk_store_config = {
          max_look_back_period = "0s";
        };

        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };

        compactor = {
          working_directory = "/srv/storage/loki";
          shared_store = "filesystem";
          compactor_ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
      };
      # user, group, dataDir, extraFlags, (configFile)
    };
  };
}
