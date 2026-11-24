---
title: Adding systems
description: How to declare a new system configuration in this flake.
---

Every host is an entry in
[`systems/fleet.toml`](https://github.com/isabelroses/dotfiles/blob/main/systems/fleet.toml).
The flake reads that file, builds a `nixosConfiguration` or
`darwinConfiguration` for each entry, and passes it through
[`mkHost`](https://github.com/isabelroses/dotfiles/blob/main/modules/flake/lib/mkhost.nix).
Every host can read the whole file, so no host has to evaluate another to learn
about it.

## The fleet entry

The top-level keys are typed by
[`systems/fleet.nix`](https://github.com/isabelroses/dotfiles/blob/main/systems/fleet.nix):

- **arch**: `"x86_64"` (default) or `"aarch64"`
- **class**: `"nixos"` (default), `"darwin"`, `"iso"`, or `"unmanaged"`.
  Unmanaged hosts aren't built, but the fleet still monitors them.
- **ipv4** / **ipv6**: the address on the host's primary interface
- **wakeOnLan**: the interface to enable Wake-on-LAN on
- **relay**: public services another host serves for this one over tailscale,
  for hosts behind NAT

Everything else becomes the host's `garden` config, so `profiles`, `device`,
`system` and `services` tables set `garden.profiles.*`, `garden.device.*` and
so on.

For example, an aarch64 server:

```toml
[skadi]
arch = "aarch64"
ipv4 = "10.0.0.11"

[skadi.profiles]
headless.enable = true
server.enable = true
oracle.enable = true

[skadi.services]
nginx.enable = true
pds.enable = true
```

A macOS host:

```toml
[tatsumaki]
arch = "aarch64"
class = "darwin"

[tatsumaki.profiles]
laptop.enable = true
graphical.enable = true
workstation.enable = true
```

The system tuple (e.g. `aarch64-linux`) is derived from `arch` and `class`.

## The host directory

Anything that needs Nix (`config`, `lib`, `pkgs`) goes in `systems/<host>/`.
Each of these files is optional and imported when present:

- `default.nix`: host-specific config
- `hardware.nix`: hardware config, usually from `nixos-generate-config`
- `users.nix`: per-host user and home-manager config

## The topology diagram

The [topology diagram](/design/topology/) is drawn from `fleet.toml`. A host
that sits at home or travels needs listing under `home` or `roaming` in
[`modules/flake/packages/topology/extra.nix`](https://github.com/isabelroses/dotfiles/blob/main/modules/flake/packages/topology/extra.nix),
along with its tailnet address. Anything unlisted is drawn in the cloud.
