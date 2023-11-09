{
  lib,
  dag,
  ...
}: let
  mkTable = desc: body:
    lib.mkOption {
      default = {};
      type = lib.types.submodule ({config, ...}: {
        options =
          {
            enable = lib.mkEnableOption desc;
            objects = lib.mkOption {
              type = with lib.types; listOf str;
              description = "Objects associated with this table.";
            };
          }
          // body;

        config = let
          buildChainDag = chain:
            lib.concatMapStringsSep "\n" ({
              name,
              data,
            }: let
              protocol =
                if builtins.isNull data.protocol
                then ""
                else data.protocol;
              field =
                if builtins.isNull data.field
                then ""
                else data.field;
              inherit (data) policy;
              values = map toString data.value;
              value =
                if builtins.isNull data.value
                then ""
                else
                  (
                    if builtins.length data.value == 1
                    then builtins.head values
                    else "{ ${lib.concatStringsSep ", " values} }"
                  );
            in ''
              ${protocol} ${field} ${value} ${policy} comment ${name}
            '') ((dag.topoSort chain).result or (throw "Cycle in DAG"));
          buildChain = chainType: chain:
            lib.mapAttrsToList (chainName: chainDag: ''
              chain ${chainName} {
                type ${chainType} hook ${chainName} priority 0;
                ${buildChainDag chainDag}
              }
            '') (lib.filterAttrs (_: g: builtins.length (builtins.attrNames g) > 0) chain);
        in {
          objects = let
            chains =
              (
                if config ? filter
                then buildChain "filter" config.filter
                else []
              )
              ++ (
                if config ? nat
                then buildChain "nat" config.nat
                else []
              )
              ++ (
                if config ? route
                then buildChain "route" config.route
                else []
              );
          in
            chains;
        };
      });
      description = "Containers for chains, sets, and other stateful objects.";
    };

  mkChain = _: description:
    lib.mkOption {
      inherit description;
      default = {};
      type = dag.types.dagOf (lib.types.submodule {
        options = {
          protocol = lib.mkOption {
            default = null;
            type = with lib.types;
              nullOr (either (enum [
                  "ether"
                  "vlan"
                  "arp"
                  "ip"
                  "icmp"
                  "igmp"
                  "ip6"
                  "icmpv6"
                  "tcp"
                  "udp"
                  "udplite"
                  "sctp"
                  "dccp"
                  "ah"
                  "esp"
                  "comp"
                ])
                str);
            description = "Protocol to match.";
          };
          field = lib.mkOption {
            default = null;
            type = with lib.types;
              nullOr (enum [
                "dport"
                "sport"
                "daddr"
                "saddr"
                "type"
                "state"
                "iifname"
                "pkttype"
              ]);
            description = "Value to match.";
          };
          value = lib.mkOption {
            default = null;
            type = with lib.types; let
              valueType = oneOf [port str];
            in
              nullOr (coercedTo valueType (v: [v]) (listOf valueType));
            description = "Associated value.";
          };
          policy = lib.mkOption {
            type = lib.types.enum [
              "accept"
              "reject"
              "drop"
              "log"
            ];
            description = "What to do with matching packets.";
          };
        };
      });
    };

  mkIngressChain = mkChain "Process all packets before they enter the system";
  mkPrerouteChain = mkChain "Process all packets entering the system";
  mkInputChain = mkChain "Process packets delivered to the local system";
  mkForwardChain = mkChain "Process packets forwarded to a different host";
  mkOutputChain = mkChain "Process packets sent by local processes";
  mkPostrouteChain = mkChain "Process all packets leaving the system";
in {
  inherit mkTable mkIngressChain mkPrerouteChain mkInputChain mkForwardChain mkOutputChain mkPostrouteChain;
}
