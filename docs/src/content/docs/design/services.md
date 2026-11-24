---
title: Services
description: How a service module is put together, and what every one gets for free.
---

Every self-hosted service is a module in
[`modules/nixos/services/`](https://github.com/isabelroses/dotfiles/tree/main/modules/nixos/services)
that a host switches on from
[`fleet.toml`](https://github.com/isabelroses/dotfiles/blob/main/systems/fleet.toml).
The [services](/services/) page lists what each host actually runs.

## The shape of a service

`garden.services.<name>` is a submodule with four options, plus anything else a
service wants to add (it's freeform):

- **enable**
- **host**: the address it binds. Defaults to `127.0.0.1` when it has a port,
  otherwise `null`
- **port**: the port it listens on, or `null`
- **domain**: where it's served, or `null`

A module declares its own defaults with
[`mkService`](/lib/modules/), which sets them at `mkOptionDefault` so the host
can still override any of them:

```nix
{ lib, self, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkService;

  cfg = config.garden.services.vaultwarden;
in
{
  imports = [
    (mkService "vaultwarden" {
      port = 3013;
      domain = "vault.${config.networking.domain}";
    })
  ];

  config = mkIf cfg.enable {
    services.vaultwarden.config = {
      ROCKET_ADDRESS = cfg.host;
      ROCKET_PORT = cfg.port;
    };

    services.nginx.virtualHosts.${cfg.domain}.locations."/".proxyPass =
      "http://${cfg.host}:${toString cfg.port}";
  };
}
```

Read the port and domain back from `cfg` rather than repeating them, so an
override in `fleet.toml` reaches everything that uses them. Other services do
the same, so vaultwarden finds its mail server at
`config.garden.services.mailserver.domain`.

## Switching it on

In `fleet.toml`, under the host's `services` table:

```toml
[minerva.services]
vaultwarden.enable = true

[freyja.services]
# bind every interface, for the relay or the tailnet to reach
immich = { enable = true, host = "0.0.0.0" }
```

## What nginx adds

Every virtual host gets these defaults from
[`nginx.nix`](https://github.com/isabelroses/dotfiles/blob/main/modules/nixos/services/nginx.nix),
so a service only says where to proxy:

- HTTPS forced, an ACME certificate, and QUIC
- a `403` for AI crawlers, matched on user agent
- the security headers `Referrer-Policy`, `Content-Security-Policy:
  frame-ancestors 'self'` and `X-Content-Type-Options`, unless the vhost sets
  `securityHeaders = false`

:::caution
`nginx.conf` is checked by gixy at build time. If a `location` adds any header
with `add_header`, it has to restate every header gixy watches that its parent
sets, or the build fails. Copy the whole set into the block and change only the
line you mean to.
:::

## Hosts behind NAT

A host that can't take public traffic, like freyja at home, names a relay in
its fleet entry:

```toml
[freyja]
relay = { via = "minerva", services = ["grafana", "immich", "jellyfin"] }
```

The relay then serves each listed service's domain and proxies it over
tailscale to the port the home host gives it. The fleet name is the tailscale
name, so nothing else needs wiring. Evaluation fails if a relayed service isn't
enabled on the host it points at. Bind those services to `0.0.0.0` so the
tailnet can reach them.

## Backups, secrets and bans

- **Backups**: add the service's state to `garden.backups.jobs.<name>.paths`.
  On a host running `borgbackup`, each job becomes a nightly borg backup to
  rsync.net. See [restoring backups](/guides/restoring-backups/).
- **Secrets**: [`mkSecret`](/lib/modules/) wires a key from
  `secrets/services/<file>.yaml` into `sops.secrets`. See [secrets](/guides/secrets/).
- **Bans**: [`journalJail`](/lib/modules/) builds a fail2ban jail that reads the
  service's journal and bans on both TCP and UDP web ports, since QUIC is on.

## Getting it documented

Nothing to do. The [services](/services/) page and each host's page are
generated from the evaluated configs on every docs build. To give a service a
proper name or logo in those pages and the topology diagram, add it to
[`modules/flake/packages/topology/catalog.nix`](https://github.com/isabelroses/dotfiles/blob/main/modules/flake/packages/topology/catalog.nix).
