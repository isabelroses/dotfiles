#!/usr/bin/env bash

set -euxo pipefail

echo "Welcome to the iznix installer!"

# get some information from the user
hostname=$(gum input --placeholder "Enter hostname")
drive=$(lsblk -nlo PATH | gum choose --header "Select drive to install to")

# create some partitions
parted "$drive" -- mklabel gpt
parted "$drive" -- mkpart boot fat32 1MB 1024MB
parted "$drive" -- mkpart root btrfs 1024MB -8GB
parted "$drive" -- mkpart swap linux-swap -8GB 100%
parted "$drive" -- set 1 esp on

# Determine partition prefix based on drive type
if [[ $drive == *"nvme"* ]]; then
  # nvme dirves like /dev/nvme0n1p1
  boot_part="${drive}p1"
  root_part="${drive}p2"
  swap_part="${drive}p3"
else
  # handle /dev/sda1 style drives
  boot_part="${drive}1"
  root_part="${drive}2"
  swap_part="${drive}3"
fi

# format the partitions
mkfs.fat -F32 -n boot "$boot_part"
mkfs.btrfs -L root "$root_part"
mkswap -L swap "$swap_part"
swapon "$swap_part"

# mount the partitions whilst ensuring the directories exist
mkdir -p /mnt
mount "$root_part" /mnt
mkdir -p /mnt/boot
mount "$boot_part" /mnt/boot

# copy across the iso's nixos flake to the target system
mkdir -p /mnt/etc/nixos
cp -rT /iso/flake /mnt/etc/nixos

# do we need to setup the host or has it been done already
new_host=$(gum confirm "Make a new host?")

# setup the system specific configuration
if [ "$new_host" ]; then
  mkdir -p /mnt/etc/nixos/systems/"$hostname"
  cp /iso/flake/modules/flake/packages/pkgs/installer/base-config.nix /mnt/etc/nixos/systems/"$hostname"/default.nix
  # force the user to setup stuff
  vim /mnt/etc/nixos/systems/"$hostname"/default.nix
fi

# setup the git repository for the nixos configuration
git -C /mnt/etc/nixos init
git -C /mnt/etc/nixos remote add origin ssh://git@github.com/isabelroses/dotfiles.git
(
  git -C /mnt/etc/nixos fetch &&
    git -C /mnt/etc/nixos reset "origin/HEAD" &&
    git -C /mnt/etc/nixos branch --set-upstream-to=origin/main main
) || true

# create some ssh keys with no passphrases
mkdir -p /mnt/etc/ssh
ssh-keygen -t ed25519 -f /mnt/etc/ssh/ssh_host_ed25519_key -N ""
ssh-keygen -t rsa -b 4096 -f /mnt/etc/ssh/ssh_host_rsa_key -N ""

# setup our installer args based off of our configuration
# this is concept is taken from https://github.com/lilyinstarlight/foosteros/blob/0d40c72ac4e81c517a7aa926b2a1fb4389124ff7/installer/default.nix
installArgs=(--no-channel-copy)
if [ "$(nix eval "/mnt/etc/nixos#nixosConfigurations.$hostname.config.users.mutableUsers")" = "false" ]; then
  installArgs+=(--no-root-password)
fi

nixos-install --flake "/mnt/etc/nixos#$hostname" "''${installArgs[*]}"
