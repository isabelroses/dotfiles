# the docs' host pages, services index and systems table. fleet.toml says what
# each host is; its evaluated config says what it actually runs, so domains and
# ports are the ones the host uses rather than what the toml happens to set
{
  lib,
  fetchurl,
  linkFarm,
  writeText,

  inputs,
  self ? inputs.self,
}:
let
  inherit (lib.attrsets)
    attrNames
    attrValues
    filterAttrs
    mapAttrs
    mapAttrsToList
    recursiveUpdate
    ;
  inherit (lib.lists)
    concatMap
    elem
    optional
    partition
    sort
    unique
    ;
  inherit (lib.strings)
    concatStrings
    concatStringsSep
    optionalString
    toLower
    toSentenceCase
    ;

  extra = import ../topology/extra.nix;
  catalog = import ../topology/catalog.nix { inherit fetchurl; };
  label = id: catalog.${id}.name or id;

  fleet = lib.trivial.importTOML "${self}/systems/fleet.toml";
  merged = recursiveUpdate fleet extra.hosts;

  repo = "https://github.com/isabelroses/dotfiles";
  enabled = filterAttrs (_: v: v.enable or false);
  byName = sort (a: b: toLower (label a.name) < toLower (label b.name));

  describe =
    name: h:
    let
      class = h.class or "nixos";
      config = if class == "nixos" then self.nixosConfigurations.${name}.config or null else null;
      profiles = attrNames (enabled (h.profiles or { }));

      relayed = n: h ? relay && elem n h.relay.services;
      nginx = config != null && config.garden.services.nginx.enable;

      service = n: s: {
        name = n;
        inherit (s) port host domain;
        # a domain is only reachable when something serves it. nginx's own
        # domain is the host's base domain, not somewhere it serves
        public = s.domain != null && n != "nginx" && (nginx || relayed n);
        via = if relayed n then h.relay.via else null;
      };

      # hosts the flake doesn't evaluate only name their services
      unknown = {
        port = null;
        host = null;
        domain = null;
      };

      services =
        if config != null then
          mapAttrsToList service (enabled config.garden.services)
        else
          map (n: service n unknown) (
            if builtins.isList (h.services or null) then h.services else attrNames (enabled (h.services or { }))
          );
    in
    {
      inherit
        name
        class
        profiles
        services
        ;
      description = h.description or "";
      arch = h.arch or "x86_64";
      relay = h.relay or null;
      ipv4 = h.ipv4 or null;
      tailnetIp = h.tailnetIp or null;
      device = h.device or { };

      kind =
        if class == "iso" then
          "ISO"
        else if elem "laptop" profiles then
          "Laptop"
        else if elem "server" profiles || class == "unmanaged" then
          "Server"
        else
          "Desktop";

      os =
        {
          nixos = "NixOS";
          iso = "NixOS";
          darwin = "macOS";
        }
        .${class} or (toSentenceCase (h.os or class));

      where = h.location or "cloud";

      backups =
        if config != null && config.garden.services.borgbackup.enable then
          attrNames (enabled config.garden.backups.jobs)
        else
          [ ];

      source =
        if builtins.pathExists "${self}/systems/${name}" then "${repo}/tree/main/systems/${name}" else null;
    };

  hosts = mapAttrs describe (filterAttrs (n: _: fleet ? ${n}) merged);

  link = h: "[${h}](/hosts/${h}/)";
  url = domain: "[${domain}](https://${domain})";
  code = v: if v == null then "—" else "`${toString v}`";

  table =
    header: rows:
    concatStringsSep "\n" (
      [
        "| ${concatStringsSep " | " header} |"
        "| ${concatStringsSep " | " (map (_: "---") header)} |"
      ]
      ++ map (r: "| ${concatStringsSep " | " r} |") rows
    )
    + "\n";

  # the hosts whose public services this one serves
  relayedBy = name: attrValues (filterAttrs (_: h: h.relay != null && h.relay.via == name) hosts);

  systems = table [ "Name" "Type" "OS" "Extra Details" ] (
    map (h: [
      (link h.name)
      h.kind
      h.os
      h.description
    ]) (byName (attrValues hosts))
  );

  hostPage =
    h:
    let
      inherit (partition (s: s.public) (byName h.services)) right wrong;
      public = right;
      internal = wrong;
      relays = relayedBy h.name;

      hardware =
        optional (h.device ? cpu) "${h.device.cpu} cpu" ++ optional (h.device ? gpu) "${h.device.gpu} gpu";

      fact = k: v: "- **${k}**: ${v}\n";
      facts = concatStrings (
        [
          (fact "Type" "${h.kind}, ${h.os} on ${h.arch}")
          (fact "Where" h.where)
        ]
        ++ optional (h.profiles != [ ]) (fact "Profiles" (concatStringsSep ", " (map code h.profiles)))
        ++ optional (hardware != [ ]) (fact "Hardware" (concatStringsSep ", " hardware))
        ++ optional (h.ipv4 != null) (fact "IPv4" (code h.ipv4))
        ++ optional (h.tailnetIp != null) (fact "Tailnet" (code h.tailnetIp))
        ++ optional (h.source != null) (fact "Source" "[systems/${h.name}](${h.source})")
      );
    in
    ''
      ---
      title: ${h.name}
      description: ${h.description}
      ---

      ${h.description}.

      ${facts}
      ${optionalString (h.class == "unmanaged") ''
        :::note
        The flake doesn't build ${h.name}. These are the services it runs on its own.
        :::
      ''}
      ${optionalString (public != [ ]) ''
        ## Public services

        ${table [ "Service" "URL" "Port" ] (
          map (s: [
            (label s.name)
            (url s.domain + optionalString (s.via != null) " (via ${link s.via})")
            (code s.port)
          ]) public
        )}''}
      ${optionalString (internal != [ ]) ''
        ## ${if public == [ ] then "Services" else "Internal services"}

        ${table [ "Service" "Binds" "Port" ] (
          map (s: [
            (label s.name)
            (code s.host)
            (code s.port)
          ]) internal
        )}''}
      ${optionalString (relays != [ ]) ''
        ## Relays

        ${h.name} serves these over tailscale for hosts that can't take public traffic themselves.

        ${table [ "Host" "Services" ] (
          map (r: [
            (link r.name)
            (concatStringsSep ", " (map label r.relay.services))
          ]) relays
        )}''}
      ${optionalString (h.backups != [ ]) ''
        ## Backups

        Backed up offsite with borg: ${concatStringsSep ", " (map label h.backups)}.
        See [restoring backups](/guides/restoring-backups/).
      ''}
    '';

  rows = partition (s: s.public) (
    concatMap (h: map (s: s // { on = h.name; }) h.services) (attrValues hosts)
  );

  # internal services are mostly the same few on every host, so one row each
  internal = mapAttrsToList (name: ss: {
    inherit name;
    hosts = map (s: s.on) ss;
    ports = unique (map (s: s.port) ss);
  }) (builtins.groupBy (s: s.name) rows.wrong);

  servicesPage = ''
    ---
    title: Services
    description: Every service the fleet runs, read from each host's evaluated config.
    ---

    Every enabled `garden.services` entry, read from each host's evaluated
    config on every docs build, so the domains and ports are the ones each host
    actually uses. Live status is at ${url "status.isabelroses.com"}. How a
    service module is put together is in [the services design notes](/design/services/).

    ## Public

    ${table [ "Service" "URL" "Host" "Port" ] (
      map (s: [
        (label s.name)
        (url s.domain)
        (link s.on + optionalString (s.via != null) " via ${link s.via}")
        (code s.port)
      ]) (byName rows.right)
    )}
    ## Internal

    These aren't served publicly. They're reached locally, over the tailnet, or
    not at all.

    ${table [ "Service" "Hosts" "Port" ] (
      map (s: [
        (label s.name)
        (concatStringsSep ", " (map link s.hosts))
        (concatStringsSep ", " (map code s.ports))
      ]) (byName internal)
    )}'';
in
linkFarm "fleet-docs" (
  [
    {
      name = "systems.md";
      path = writeText "systems.md" systems;
    }
    {
      name = "content/services.md";
      path = writeText "services.md" servicesPage;
    }
  ]
  ++ mapAttrsToList (n: h: {
    name = "content/hosts/${n}.md";
    path = writeText "${n}.md" (hostPage h);
  }) hosts
)
