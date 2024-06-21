{ config, ... }:
let
  inherit (config.lib.topology)
    mkInternet
    mkDevice
    mkSwitch
    mkRouter
    mkConnection
    ;
in
{
  nodes.printer = mkDevice "Printer Attic" {
    info = "Epson XP-7100";
    connections.eth1 = mkConnection "switch-attic" "eth5";
  };
}
