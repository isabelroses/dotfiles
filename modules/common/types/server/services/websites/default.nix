{
  config,
  lib,
  ...
}: let
  cfg = config.modules.usrEnv.services;
  inherit (config.networking) domain;
in {
  config.services.phpfpm.pools.${domain} = lib.mkIf cfg.enable {
    user = config.services.nginx.user;
    settings = {
      "listen.owner" = config.services.nginx.user;
      "listen.group" = config.services.nginx.group;
      "listen.mode" = "0660";
      "pm" = "dynamic";
      "pm.max_children" = 75;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 20;
      "pm.max_requests" = 500;
      "catch_workers_output" = true;
    };
  };
}
