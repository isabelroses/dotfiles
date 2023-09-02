{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  sys = config.modules.system.virtualization;
in {
  config = mkIf sys.enable {
    environment.systemPackages = with pkgs;
      []
      ++ optionals sys.qemu.enable [
        virt-manager
        virt-viewer
      ]
      ++ optionals sys.docker.enable [
        podman-compose
        podman-desktop
      ]
      ++ optionals sys.distrobox.enable [
        distrobox
      ]
      ++ optionals sys.waydroid.enable [
        waydroid
      ];

    virtualisation = {
      # qemu
      kvmgt.enable = sys.qemu.enable && config.modules.device.type == "intel";
      spiceUSBRedirection.enable = sys.qemu.enable;
      libvirtd = mkIf sys.qemu.enable {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          ovmf = {
            enable = true;
            packages = [pkgs.OVMFFull.fd];
          };
          swtpm.enable = true;
        };
      };

      # podman
      podman = mkIf sys.docker.enable {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings = {
          dns_enabled = true;
        };
        enableNvidia = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;
        autoPrune = {
          enable = true;
          flags = ["--all"];
          dates = "weekly";
        };
      };

      waydroid.enable = sys.waydroid.enable;
      lxd.enable = mkDefault config.virtualisation.waydroid.enable;
    };
  };
}
