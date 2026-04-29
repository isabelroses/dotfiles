---
title: Installation
description: How to install this configuration on NixOS or macOS.
---

## NixOS

You might want to use the [lilith ISO configuration](/design/topology/#systems), provided in this repository.

- To build it, run `just iso lilith`.
- Or download it from the [release page](https://github.com/isabelroses/dotfiles/releases/latest).

If you opted to use the lilith ISO image, you can use the `iztaller` script to partition the target disk and install the system. Otherwise, follow the steps below.

1. Install [NixOS](https://nixos.org/download); you might need to follow the [manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation).
2. Clone this repository to `~/.config/flake`.
3. Run `sudo nixos-rebuild switch --flake ~/.config/flake#<host>`.

### Dual boot

If you'd like to set up dual boot with Windows, you should consider enabling secure boot. To do so, follow the [lanzaboote guide](https://github.com/nix-community/lanzaboote/blob/0bc127c631999c9555cae2b0cdad2128ff058259/docs/QUICK_START.md).

1. Locate the Windows EFI partition:

   ```sh
   lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT
   ```

2. Mount the Windows EFI partition:

   ```sh
   sudo mkdir /mnt/winboot
   sudo mount /dev/nvme0n1p1 /mnt/winboot
   ```

3. Copy the Windows EFI files to the NixOS EFI partition:

   ```sh
   sudo rsync -av /mnt/winboot/EFI/Microsoft/ /boot/EFI/Microsoft/
   ```

4. Finally, clean up:

   ```sh
   sudo umount /mnt/winboot
   sudo rmdir /mnt/winboot
   ```

## macOS

1. Install [Lix](https://lix.systems/install/), the package manager:

   ```sh
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

2. Enter a Nix development shell in order to use git and other required tools:

   ```sh
   nix develop
   ```

3. Switch to the configuration. Replace `<host>` with the system you are configuring:

   ```sh
   just provision <host>
   ```

## Imperative steps

- Login to atuin
- Login to gh CLI
- Install user scripts:
  - [bleh](https://github.com/katelyynn/bleh/raw/uwu/fm/bleh.user.js)
  - [Info for merged pull requests](https://github.com/isabelroses/userscripts/raw/refs/heads/main/src/prs/script.user.js)
  - [bluesky hide followers & likes](https://github.com/isabelroses/userscripts/raw/refs/heads/main/src/bsky-hide-follows/script.user.js)
- Grab all my scripts: `git clone me:isabel/skid ~/.local/bin`
