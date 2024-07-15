{ lib }:
let
  inherit (lib.types) str;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.attrsets) recursiveUpdate;

  # make a service that is a part of the graphical session target
  mkGraphicalService = recursiveUpdate {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = [ "graphical-session.target" ];
  };

  mkHyprlandService = recursiveUpdate {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  mkServiceOption =
    name:
    {
      port ? 0,
      host ? "127.0.0.1",
      domain ? "",
      extraConfig ? { },
    }:
    {
      enable = mkEnableOption "Enable the ${name} service";

      host = mkOption {
        type = str;
        default = host;
        description = "The host for ${name} service";
      };

      port = mkOption {
        type = lib.types.port;
        default = port;
        description = "The port for ${name} service";
      };

      domain = mkOption {
        type = str;
        default = domain;
        description = "Domain name for the ${name} service";
      };
    }
    // extraConfig;
in
{
  inherit mkGraphicalService mkHyprlandService mkServiceOption;
}
