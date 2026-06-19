#!/usr/bin/env bash

set -euxo pipefail

die() {
  echo "iztaller: $*" >&2
  exit 1
}

# For a device name like /dev/sda1, find a more stable path like
# /dev/disk/by-uuid/X or /dev/disk/by-label/Y. This is a port of
# `findStableDevPath` from nixos-generate-config.pl: we compare the
# device numbers (rdev) rather than trusting any particular symlink.
find_stable_dev_path() {
  local dev="$1"
  [[ "${dev:0:1}" == "/" ]] || {
    printf '%s' "$dev"
    return
  }
  [[ -e "$dev" ]] || {
    printf '%s' "$dev"
    return
  }

  local rdev cand rdev2
  rdev=$(stat -L -c '%t:%T' "$dev" 2>/dev/null) || {
    printf '%s' "$dev"
    return
  }

  for cand in /dev/mapper/* /dev/disk/by-uuid/* /dev/disk/by-label/*; do
    [[ -e "$cand" ]] || continue
    rdev2=$(stat -L -c '%t:%T' "$cand" 2>/dev/null) || continue
    if [[ "$rdev2" == "$rdev" ]]; then
      printf '%s' "$cand"
      return
    fi
  done

  printf '%s' "$dev"
}

# Returns true if $1 is $2 or lives underneath it (e.g. "/proc/foo" in "/proc").
is_in() {
  [[ "$1" == "$2" || "${1:0:$((${#2} + 1))}" == "$2/" ]]
}

# Generate the `fileSystems` and `swapDevices` options from what is currently
# mounted/active under $1 (the root directory, e.g. /mnt). This is an inline
# reimplementation of the relevant parts of nixos-generate-config.pl so we
# don't have to depend on the full hardware scan -- our hardware.nix only ever
# carries filesystems and swap. The emitted Nix is intentionally terse and is
# run through `nixfmt` by the caller.
generate_hardware_config() {
  # this loop is far too noisy under `set -x`
  { set +x; } 2>/dev/null

  local root_dir="$1"
  local file_systems=""
  local -A fs_by_dev=()
  local -a swap_devices=()

  # --- filesystems, from /proc/self/mountinfo ---------------------------------
  local line
  while IFS= read -r line; do
    local -a f
    read -ra f <<<"$line"

    local mount_point="${f[4]}"
    mount_point="${mount_point//\\040/ }"     # spaces are escaped as \040
    mount_point="${mount_point//\\011/$'\t'}" # tabs are escaped as \011
    [[ -d "$mount_point" ]] || continue

    local mount_options="${f[5]}"

    # only consider things mounted under the target root, and strip its prefix
    is_in "$mount_point" "$root_dir" || continue
    mount_point="${mount_point:${#root_dir}}"
    [[ -z "$mount_point" ]] && mount_point="/"

    # skip special filesystems
    local sp skip=0
    for sp in /proc /dev /sys /run; do
      if is_in "$mount_point" "$sp"; then
        skip=1
        break
      fi
    done
    [[ "$skip" == 1 || "$mount_point" == "/var/lib/nfs/rpc_pipefs" ]] && continue

    # locate the separator ("-") and read the post-separator fields
    local n=6
    while [[ "${f[$n]}" != "-" ]]; do n=$((n + 1)); done
    n=$((n + 1))
    local fs_type="${f[$n]}"
    local device="${f[$((n + 1))]}"
    local super_options="${f[$((n + 2))]}"
    device="${device//\\040/ }"
    device="${device//\\011/$'\t'}"

    # skip the read-only bind-mount on /nix/store
    if [[ "$mount_point" == "/nix/store" && ",$super_options," == *,rw,* && ",$mount_options," == *,ro,* ]]; then
      continue
    fi

    local devid="${f[2]}"
    local -a extra_options=()

    # maybe this is a bind-mount of a filesystem we saw earlier? (unless it is
    # actually a btrfs subvolume of one)
    if [[ -n "${fs_by_dev[$devid]:-}" ]] && ! btrfs subvol show "$root_dir$mount_point" >/dev/null 2>&1; then
      local path="${f[3]}"
      [[ "$path" == "/" ]] && path=""
      local base="${fs_by_dev[$devid]}"
      [[ "$base" == "/" ]] && base=""
      file_systems+="\"$mount_point\" = { device = \"$base$path\"; fsType = \"none\"; options = [ \"bind\" ]; };"$'\n'
      continue
    fi
    fs_by_dev[$devid]="$mount_point"

    # we don't know how to handle FUSE filesystems
    if [[ "$fs_type" == "fuseblk" || "$fs_type" == "fuse" ]]; then
      echo "warning: don't know how to emit 'fileSystems' option for FUSE filesystem '$mount_point'" >&2
      continue
    fi

    # is this a mount of a loopback device?
    if [[ "$device" =~ ^/dev/loop([0-9]+)$ ]]; then
      local backer
      backer=$(cat "/sys/block/loop${BASH_REMATCH[1]}/loop/backing_file" 2>/dev/null) || true
      if [[ -n "$backer" ]]; then
        device="$backer"
        extra_options+=("loop")
      fi
    fi

    # is this a btrfs filesystem? if so, record the subvolume
    if [[ "$fs_type" == "btrfs" ]]; then
      local info status
      info=$(btrfs subvol show "$root_dir$mount_point" 2>&1) && status=0 || status=$?
      if [[ "$status" != 0 || "$info" == *ERROR:* ]]; then
        die "Failed to retrieve subvolume info for $mount_point"
      fi
      local first_line="${info%%$'\n'*}"
      if [[ "$first_line" != "/" && "$info" == *"Subvolume ID:"* ]]; then
        extra_options+=("subvol=$first_line")
      fi
    fi

    # preserve fmask/dmask for vfat so the ESP isn't world-readable
    if [[ "$fs_type" == "vfat" ]]; then
      local -a sopts o
      IFS=',' read -ra sopts <<<"$super_options"
      for o in "${sopts[@]}"; do
        [[ "$o" == fmask* || "$o" == dmask* ]] && extra_options+=("$o")
      done
    fi

    # /tmp on tmpfs is handled declaratively by boot.tmp.useTmpfs
    [[ "$mount_point" == "/tmp" && "$fs_type" == "tmpfs" ]] && continue

    local stable
    stable=$(find_stable_dev_path "$device")

    local entry="\"$mount_point\" = { device = \"$stable\"; fsType = \"$fs_type\";"
    if [[ "${#extra_options[@]}" -gt 0 ]]; then
      # uniq, preserving order
      local -a uniq=() seen u
      for o in "${extra_options[@]}"; do
        seen=0
        for u in "${uniq[@]}"; do [[ "$u" == "$o" ]] && seen=1 && break; done
        [[ "$seen" == 0 ]] && uniq+=("$o")
      done
      entry+=" options = ["
      for o in "${uniq[@]}"; do entry+=" \"$o\""; done
      entry+=" ];"
    fi
    entry+=" };"
    file_systems+="$entry"$'\n'
  done </proc/self/mountinfo

  # --- swap, from /proc/swaps -------------------------------------------------
  local swap fields
  while IFS= read -r swap; do
    local -a fields
    read -ra fields <<<"$swap"
    [[ "${fields[0]}" == "Filename" ]] && continue # header
    local swap_filename="${fields[0]}" swap_type="${fields[1]}"
    [[ -e "$swap_filename" ]] || continue
    if [[ "$swap_type" == *partition* ]]; then
      # zram swap is created declaratively, ignore it here
      [[ "$swap_filename" == /dev/zram* ]] && continue
      swap_devices+=("{ device = \"$(find_stable_dev_path "$swap_filename")\"; }")
    elif [[ "$swap_type" == *file* ]]; then
      : # swap files are configured declaratively, ignore them here
    else
      die "Unsupported swap type: $swap_type"
    fi
  done </proc/swaps

  # --- emit (minimal, valid Nix; nixfmt prettifies it later) ------------------
  {
    printf '{\n'
    printf '  fileSystems = {\n%s  };\n' "$file_systems"
    if [[ "${#swap_devices[@]}" -gt 0 ]]; then
      printf '  swapDevices = ['
      printf ' %s' "${swap_devices[@]}"
      printf ' ];\n'
    fi
    printf '}\n'
  }

  { set -x; } 2>/dev/null
}

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

mkdir -p /mnt/etc/nixos/systems/"$hostname"
generate_hardware_config /mnt | nixfmt >/mnt/etc/nixos/systems/"$hostname"/hardware.nix

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

echo "When you are ready to install, run the following command:"
echo nixos-install --flake "/mnt/etc/nixos#$hostname" "''${installArgs[*]}"
