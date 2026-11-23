{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.lists) filter elem;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.strings) concatMapStringsSep concatStringsSep;
  inherit (self.lib) mkService;

  inherit (config.networking) hostName;
  inherit (config.garden) fleet;

  registry = import ./exporters/registry.nix { inherit lib; };
  loki = registry.locate "loki" fleet config.garden.services;

  cfg = config.garden.services.fluent-bit;

  fields = [
    "unit"
    "priority"
    "identifier"
  ];

  # TODO: which of `fields` become loki labels. every distinct value of a label
  # is its own stream, so unit is cheap and worth filtering on, while anything
  # per-process belongs in the line. the rest are dropped from what's sent
  labels = [ ];

  journal = ''
    local priorities = { [0] = "emerg", "alert", "crit", "err", "warning", "notice", "info", "debug" }

    function journal(tag, ts, record)
      local out = {
        message = record["MESSAGE"],
        unit = record["_SYSTEMD_UNIT"] or record["_TRANSPORT"],
        identifier = record["SYSLOG_IDENTIFIER"],
      }
      local p = tonumber(record["PRIORITY"])
      if p ~= nil then out.priority = priorities[p] end
      return 1, ts, out
    end
  '';
in
{
  imports = [ (mkService "fluent-bit" { }) ];

  config = {
    garden.services.fluent-bit.enable = mkDefault (fleet ? ${hostName} && loki != null);

    systemd.services.fluent-bit.serviceConfig.StateDirectory = mkIf cfg.enable "fluent-bit";

    services.fluent-bit = mkIf cfg.enable {
      enable = true;

      settings = {
        service = {
          flush = 1;
          log_level = "warn";
        };

        pipeline = {
          inputs = [
            {
              name = "systemd";
              tag = "journal";
              db = "/var/lib/fluent-bit/journal.db";
              read_from_tail = "on";
            }
          ];

          filters = [
            {
              name = "lua";
              match = "journal";
              call = "journal";
              code = journal;
            }
          ];

          outputs = [
            (
              {
                name = "loki";
                match = "journal";
                inherit (loki) host port;
                labels = "job=journal, host=${hostName}";
                remove_keys = concatStringsSep "," (filter (f: !elem f labels) fields);
                drop_single_key = "raw";
              }
              // optionalAttrs (labels != [ ]) {
                label_keys = concatMapStringsSep "," (l: "$" + l) labels;
              }
            )
          ];
        };
      };
    };
  };
}
