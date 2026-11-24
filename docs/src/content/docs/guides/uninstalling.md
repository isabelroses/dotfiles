---
title: Uninstalling
description: How to remove this configuration from NixOS or macOS.
---

## NixOS

There's nothing to uninstall on NixOS. The whole system is the configuration,
so moving away from this flake means switching to another one:

```sh
sudo nixos-rebuild switch --flake /path/to/your/flake#hostname
```

Old generations stay in the boot menu until you collect them, so you can still
boot back into this config. When you're sure, run `just clean` or
`nix-collect-garbage --delete-older-than 3d`.

## macOS

To uninstall nix-darwin, run the following command:

```sh
nix run github:LnL7/nix-darwin#darwin-uninstaller
```

This removes nix-darwin and the system configuration but leaves Nix itself
installed. Homebrew casks this flake installed through nix-darwin stay too;
remove them with `brew uninstall` if you don't want them.

To remove Lix as well, use the installer it left behind:

```sh
/nix/lix-installer uninstall
```
