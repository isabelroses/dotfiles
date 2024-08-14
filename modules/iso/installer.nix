{
  nix,
  gum,
  parted,
  nixos-install-tools,
  writeShellApplication,
}:
writeShellApplication {
  name = "iznix-install";

  runtimeInputs = [
    nix
    gum
    parted
    nixos-install-tools # for nixos-install
  ];

  text = ''
    set -euxo pipefail

    echo "Welcome to the iznix installer!"
    sleep 1
    echo "Make sure you have edited the /root/flake/modules/iso/base-config.nix file in the flake to match your desired configuration"

    # get some information from the user
    hostname=$(gum input --placeholder "Enter hostname")
    drive=$(lsblk -nlo NAME | gum choose --header "Select drive to install to")

    # create some partitions
    parted "$drive" -- mklabel gpt
    parted "$drive" -- mkpart root btrfs 1024MB -8GB
    parted "$drive" -- mkpart swap linux-swap -8GB 100%
    parted "$drive" -- mkpart boot fat32 1MB 1024MB
    parted "$drive" -- set 3 esp on

    # setup the system specific configuration
    mkdir -p /root/flake/"$hostname"
    cp /root/flake/modules/iso/base-config.nix /root/flake/systems/"$hostname"/default.nix

    # copy across the iso's nixos flake to the target system
    mkdir -p /mnt/etc/nixos
    cp -rT /root/flake /mnt/etc/nixos

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
