{ lib, ... }:
let
  # make a service that is a part of the graphical session target
  mkGraphicalService = lib.recursiveUpdate {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = [ "graphical-session.target" ];
  };

  mkHyprlandService = lib.recursiveUpdate {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = [ "hyprland-session.target" ];
  };
in
{
  inherit mkGraphicalService mkHyprlandService;
}
