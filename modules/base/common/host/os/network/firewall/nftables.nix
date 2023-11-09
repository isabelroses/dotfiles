{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault optionalString dag concatStringsSep;

  sys = config.modules.system;
  cfg = config.networking.nftables;
in {
  config = mkIf sys.networking.nftables.enable {
    boot.extraModprobeConfig = optionalString cfg.enable ''
      install ip_tables ${pkgs.coreutils}/bin/true
    '';

    networking.nftables = {
      enable = true;

      rules = {
        inet = {
          input = {
            loopback = dag.entryAnywhere {
              field = "iifname";
              value = "lo";
              policy = "accept";
            };

            established-locally = dag.entryAfter ["loopback"] {
              protocol = "ct";
              field = "state";
              value = ["established" "related"];
              policy = "accept";
            };

            basic-icmp = dag.entryAfter ["loopback" "established-locally"] {
              protocol = "ip protocol icmp icmp";
              field = "type";
              value = [
                "destination-unreachable"
                "router-advertisement"
                "time-exceeded"
                "parameter-problem"
              ];
              policy = "accept";
            };

            basic-icmp6 = dag.entryAfter ["loopback" "established-locally"] {
              protocol = "ip6 nexthdr icmpv6 icmpv6";
              field = "type";
              value = [
                "destination-unreachable"
                "packet-too-big"
                "time-exceeded"
                "parameter-problem"
                "nd-router-advert"
                "nd-neighbor-solicit"
                "nd-neighbor-advert"
                #"mld-listener-query" "nd-router-solicit" # for routers
              ];
              policy = "accept";
            };

            ping = dag.entryBefore ["basic-icmp"] {
              protocol = "ip protocol icmp icmp";
              field = "type";
              value = "echo-request";
              policy = "accept";
            };

            ping6 = dag.entryBefore ["basic-icmp6"] {
              protocol = "ip6 nexthdr icmpv6 icmpv6";
              field = "type";
              value = "echo-request";
              policy = "accept";
            };

            ssh = dag.entryBetween ["basic-icmp6" "basic-icmp" "ping6" "ping"] ["default"] {
              protocol = "tcp";
              field = "dport";
              policy = "accept";
              value = config.services.openssh.ports;
            };

            default = dag.entryAfter ["loopback" "established-locally" "basic-icmp6" "basic-icmp" "ping6" "ping"] {
              policy = lib.mkDefault "drop";
            };
          };

          filter = {
            output = {
              default = dag.entryAnywhere {
                policy = "accept";
              };
            };

            forward = {
              default = dag.entryAnywhere {
                policy = "accept";
              };
            };
          };
        };
      };

      ruleset =
        mkDefault
        (concatStringsSep "\n" (lib.mapAttrsToList (name: table:
          lib.optionalString (builtins.length table.objects > 0) ''
            table ${name} nixos {
              ${concatStringsSep "\n" table.objects}
            }
          '')
        cfg.rules));
    };
  };
}
