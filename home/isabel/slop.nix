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

  basedir = config.xdg.configHome;

  # systemd user services don't go through a login shell, so source the same
  # session vars (GOPATH, PATH additions, $UID expansion, ...) that shells get
  t3code-wrapped = pkgs.writeShellScript "t3code-server" ''
    . ${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh
    exec ${getExe extpkgs.t3code-server} "$@"
  '';

  cond = config.garden.profiles.workstation.enable && pkgs.stdenv.hostPlatform.isLinux;
in
{
  config = mkIf cond {
    garden.packages = {
      inherit (extpkgs) t3code-server;
    };

    home.sessionVariables = {
      T3CODE_HOME = "${basedir}/t3";
      CLAUDE_CONFIG_DIR = "${basedir}/claude";
      CODEX_HOME = "${basedir}/codex";
      GROK_HOME = "${basedir}/grok";
    };

    systemd.user.services.t3code-server = {
      Unit.Description = "t3code server";

      Service = {
        Type = "simple";
        ExecStart = "${t3code-wrapped} serve --lan";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
