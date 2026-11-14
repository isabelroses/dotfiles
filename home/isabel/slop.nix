{
  lib,
  pkgs,
  config,
  extpkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;

  cond = config.garden.profiles.workstation.enable && pkgs.stdenv.hostPlatform.isLinux;
in
{
  config = mkIf cond {
    garden.packages = {
      inherit (extpkgs) t3code-server;
    };

    systemd.user.services.t3code-server = {
      Unit.Description = "t3code server";

      Service = {
        Type = "simple";
        ExecStart = "${getExe extpkgs.t3code-server} serve --lan";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
