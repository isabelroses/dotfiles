{
  lib,
  pkgs,
  config,
  inputs',
  ...
}: {
  systemd.services."blahaj" = lib.mkIf config.modules.services.blahaj.enable {
    description = "blahaj";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      EnvironmentFile = config.age.secrets.blahaj-env.path;
      ExecStart = "${lib.getExe pkgs.nodejs-slim} ${inputs'.blahaj.packages.default}/lib/node_modules/blahaj/src/bot.js";
      Restart = "always";
    };
  };
}
