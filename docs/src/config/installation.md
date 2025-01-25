# NixOS

You might want to use the [lilith iso configuration](./systems/lilith/), provided in this repository

- To build it you can run `nix build .#images.lilith`.
- Or you can download it from the [release page](https://github.com/isabelroses/dotfiles/releases/latest).

If you opted to use the lilith iso image, you can use the `iznix-install`
script to install it on your system. Otherwise, you can follow the steps below.

1. Install [NixOS](https://nixos.org/download), you might need to follow the [manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation)
2. Clone this repository to `~/.config/flake`
3. Run `sudo nixos-rebuild switch --flake ~/.config/flake#<host>`

## Dual boot

If you would like to set up duel boot with Windows, you should consider
enabling secure boot. To do so you should follow the [lanzaboote
guide](https://github.com/nix-community/lanzaboote/blob/0bc127c631999c9555cae2b0cdad2128ff058259/docs/QUICK_START.md).

1. Locate the Windows EFI partition

```sh
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT
```

2. Mount the Windows EFI partition

```sh
sudo mkdir /mnt/winboot
sudo mount /dev/nvme0n1p1 /mnt/winboot
```

3. Copy the Windows EFI files to the NixOS EFI partition

```sh
sudo rsync -av /mnt/winboot/EFI/Microsoft/ /boot/EFI/Microsoft/
```

4. Finally, clean up

```sh
sudo umount /mnt/winboot
sudo rmdir /mnt/winboot
```

# macOS

1. Install [Lix](https://lix.systems/install/) the package manager

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

2. Then enter a nix development shell in order to use git and other required
   tools

```sh
nix develop
```

3. Now we need to switch to the configuration, remember to replace `<host>`
   with the system you are configuring

```sh
just provision <host>
```
