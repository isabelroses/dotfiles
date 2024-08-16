{
  nix,
  gum,
  vim,
  parted,
  nixos-install-tools,
  writeShellApplication,
}:
writeShellApplication {
  name = "iznix-install";

  runtimeInputs = [
    nix
    gum
    vim
    parted
    nixos-install-tools # for nixos-install
  ];

  text = ''
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

    # format the partitions
    mkfs.fat -F32 -n boot "$drive"1
    mkfs.btrfs -L root "$drive"2

    # mount the partitions whilst ensuring the directories exist
    mkdir -p /mnt
    mount "$drive"2 /mnt
    mkdir -p /mnt/boot
    mount "$drive"1 /mnt/boot

    # copy across the iso's nixos flake to the target system
    mkdir -p /mnt/etc/nixos
    cp -rT /iso/flake /mnt/etc/nixos

    # setup the system specific configuration
    mkdir -p /mnt/etc/nixos/systems/"$hostname"
    cp /iso/flake/modules/iso/base-config.nix /mnt/etc/nixos/systems/"$hostname"/default.nix
    # force the user to setup stuff
    vim /mnt/etc/nixos/systems/"$hostname"/default.nix

    # setup the git repository for the nixos configuration
    git -C /mnt/etc/nixos init
    git -C /mnt/etc/nixos remote add origin ssh://git@github.com/isabelroses/dotfiles.git
    (
      git -C /mnt/etc/nixos fetch && \
      git -C /mnt/etc/nixos reset "origin/HEAD" && \
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

    nixos-install --flake "/mnt/etc/nixos#$hostname" "''${installArgs[@]}"
  '';
}
