{
  lib,
  config,
  self',
  ...
}:
let
  izshell = self'.legacyPackages.izshell;
in
{
  # the shell is a package (modules/flake/packages/izshell); home-manager's
  # quickshell module only puts it on PATH, for `izshell ipc ...`
  config = lib.modules.mkIf config.programs.quickshell.enable {
    programs.quickshell.package = izshell;

    systemd.user.services.izshell = {
      Unit = {
        Description = "izshell";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.meta.getExe izshell;
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
