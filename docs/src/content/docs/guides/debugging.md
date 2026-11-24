---
title: Debugging
description: How to inspect, test and recover the flake when something goes wrong.
---

## Poke at a host's config

`just repl-host` opens a Nix REPL on a host's evaluated config, the current
machine by default:

```console
$ just repl-host freyja
nix-repl> config.garden.services.immich.port
3007

nix-repl> config.services.nginx.virtualHosts."photos.isabelroses.com".locations
```

For a single value, `nix eval` is quicker:

```sh
nix eval .#nixosConfigurations.minerva.config.garden.services.forgejo.domain
```

## Search every host at once

Load the flake with `:lf` and use [`nix-select`](https://clan.lol/blog/nix-select/)
to query across all configurations:

```console
nix-repl> :lf .

nix-repl> select = (builtins.getFlake "github:clan-lol/select").lib.select

nix-repl> select "*.config.boot.swraid.enable" nixosConfigurations
```

## Check before you deploy

- `just check` runs `nix flake check` with import-from-derivation turned off,
  the same way CI does
- `just test` switches the local machine without adding a boot entry, so a
  reboot undoes it
- `just deploy-dry <host>` shows what a deploy would restart without switching
- `just deploy <host>` records the deploy with lethe and prints a diff of what
  changed

## When a rebuild fails

**`getting the HEAD of the Git tree ... failed`**: you ran
`sudo nixos-rebuild --flake .`, so root evaluated the flake and couldn't read
your git checkout. Use `just switch` or `just boot` instead, which evaluate and
build as you and only elevate to activate.

**An nginx build fails in gixy**: a `location` added an `add_header` without
restating the headers its parent sets. See [what nginx adds](/design/services/#what-nginx-adds).

**A relay assertion fails**: a host lists a service under `relay.services` in
`fleet.toml` without enabling it. Enable it on that host, or drop it from the
relay list.

**Store corruption** (hash mismatches, missing paths): `just verify` checks the
store, and `just repair` checks the contents and repairs what it can.

## Roll back

Every switch keeps the previous generation. Pick an older one from the boot
menu, or switch back from a running system:

```sh
sudo nixos-rebuild switch --rollback
# on macOS
sudo darwin-rebuild switch --rollback
```
