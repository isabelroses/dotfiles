{
  lib,
  config,
  modulesPath,
  ...
}:
let
  inherit (lib.modules) mkForce;
in
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  config = {
    services = {
      smartd.enable = mkForce false; # Unavailable - device lacks SMART capability.

      # Needed by the Hetzner Cloud password reset feature
      qemuGuest.enable = true;
    };

    boot = {
      growPartition = !config.boot.initrd.systemd.enable;
      kernelParams = [ "net.ifnames=0" ];
      kernel.sysctl = {
        "net.ipv4.ip_forward" = true;
        "net.ipv6.conf.all.forwarding" = true;
      };

      initrd.availableKernelModules = [
        "uhci_hcd"
        "xen_blkfront"
        "vmw_pvscsi"
      ];

      loader.grub = {
        enable = true;
        useOSProber = mkForce false;
        efiSupport = mkForce false;
        enableCryptodisk = false;
        theme = mkForce null;
        backgroundColor = mkForce null;
        splashImage = mkForce null;
        device = mkForce "/dev/sda";
      };
    };

    # See
    # - https://docs.hetzner.com/cloud/servers/static-configuration/
    # - https://gist.github.com/nh2/6814728dc3bea1508323e9bf2213c28d#file-configuration-nix-L39-L65
    # - https://github.com/nix-community/nixos-install-scripts/issues/3#issuecomment-752781335
    networking = {
      defaultGateway = {
        address = "172.31.1.1";
        interface = "ens3";
      };

      defaultGateway6 = {
        address = "fe80::1";
        interface = "ens3";
      };
    };
  };
}
