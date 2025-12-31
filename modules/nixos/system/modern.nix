# to quite an opinionated stance i think all these options help create a more
# modern nixos feel this happens by removing parts of the system i don't really
# like i.e. perl, mutable /etc, activation scripts etc. a lot of these options
# are also directly needed by each other to work.
#
# WARNING: some of these options are experimental meaning they will and can
# break things. so use at your own risk
{
  # We enable Systemd in the initrd so we can use it to mount the root
  # filesystem this will remove Perl form the activation
  boot.initrd.systemd.enable = true;

  # Declarative user management
  # either use this or systemd-sysusers :D
  services.userborn.enable = true;

  system = {
    # nixos-init will going to make our system more robust in principal
    # see <https://github.com/NixOS/nixpkgs/blob/9bf13c9c35c9e80fab6fa3161ec0a09c1ec9a3be/pkgs/by-name/ni/nixos-init/README.md>
    nixos-init.enable = true;

    # WARNING: this is the default, but this is here just to warn you not to change it
    # at least for now as it will mean that /etc will not be re mounted on rebuilds
    activatable = true;

    # mount /etc as a read-only overlay filesystem
    etc.overlay.enable = true;
  };
}
