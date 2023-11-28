{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkRuleset optionalString entryBefore entryBetween entryAfter entryAnywhere;

  sys = config.modules.system;
  cfg = config.networking.nftables;

  check-results =
    pkgs.runCommand "check-nft-ruleset" {
      ruleset = pkgs.writeText "nft-ruleset" cfg.ruleset;
    } ''
      mkdir -p $out
      ${pkgs.nftables}/bin/nft -c -f $ruleset 2>&1 > $out/message \
        && echo false > $out/assertion \
        || echo true > $out/assertion
    '';
in {
  config = mkIf sys.networking.nftables.enable {
    boot.extraModprobeConfig = optionalString cfg.enable ''
      install ip_tables ${pkgs.coreutils}/bin/true
    '';

    networking.nftables = {
      enable = true;
      ruleset = mkRuleset cfg.rules;

      rules = {
        inet = {
          filter = {
            input = {
              loopback = entryAnywhere {
                field = "iifname";
                value = "lo";
                policy = "accept";
              };

              established-locally = entryAfter ["loopback"] {
                protocol = "ct";
                field = "state";
                value = ["established" "related"];
                policy = "accept";
              };

              basic-icmp6 = entryAfter ["loopback" "established-locally"] {
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

              basic-icmp = entryAfter ["loopback" "established-locally"] {
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

              ping6 = entryBefore ["basic-icmp6"] {
                protocol = "ip6 nexthdr icmpv6 icmpv6";
                field = "type";
                value = "echo-request";
                policy = "accept";
              };

              ping = entryBefore ["basic-icmp"] {
                protocol = "ip protocol icmp icmp";
                field = "type";
                value = "echo-request";
                policy = "accept";
              };

              ssh = entryBetween ["basic-icmp6" "basic-icmp" "ping6" "ping"] ["default"] {
                protocol = "tcp";
                field = "dport";
                value = config.services.openssh.ports;
                policy = "accept";
              };

              default = entryAfter ["loopback" "established-locally" "basic-icmp6" "basic-icmp" "ping6" "ping"] {
                policy = lib.mkDefault "drop";
              };
            };

            output = {
              default = entryAnywhere {
                policy = "accept";
              };
            };

            forward = {
              default = entryAnywhere {
                policy = "accept";
              };
            };
          };
        };
      };
    };

    assertions = [
      {
        message = ''
          Bad config:
          ${builtins.readFile "${check-results}/message"}
        '';
        assertion = import "${check-results}/assertion";
      }
    ];

    system.extraDependencies = [check-results]; # pin IFD as a system dependency
  };
}
