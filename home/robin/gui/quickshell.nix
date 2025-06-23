{ lib, config, ... }:
let inherit (lib) mkIf mkDefault;
in {
  config = {
    programs.quickshell = {
      enable = mkDefault (config.garden.profiles.graphical.enable
        && config.garden.programs.defaults.bar == "quickshell");
    };

    systemd.user.services.quickshell-lock =
      let cfg = config.programs.quickshell;
      in mkIf cfg.enable {
        Unit = {
          Description = "launch quickshell lock";
          Before = "lock.target";
        };
        Install = { WantedBy = [ "lock.target" ]; };
        Service = {
          ExecStart = "${lib.getExe cfg.package} ipc call lock lock";
        };
      };
  };
}
