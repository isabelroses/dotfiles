{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.lists) optionals;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  sys = config.garden.system;
  cfg = sys.virtualization;
in
{
  options.garden.system.virtualization = {
    enable = mkEnableOption "Should the device be allowed to virtualizle processes";
    docker.enable = mkEnableOption "docker";
    podman.enable = mkEnableOption "podman";
    qemu.enable = mkEnableOption "qemu";
    distrobox.enable = mkEnableOption "distrobox";
    waydroid.enable = mkEnableOption "waydroid";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      optionals cfg.qemu.enable [
        pkgs.virt-manager
        pkgs.virt-viewer
      ]
      ++ optionals cfg.docker.enable [
        pkgs.podman
        pkgs.podman-compose
      ]
      ++ optionals (cfg.docker.enable && sys.video.enable) [ pkgs.lxd-lts ]
      ++ optionals cfg.distrobox.enable [ pkgs.distrobox ]
      ++ optionals cfg.waydroid.enable [ pkgs.waydroid ];

    virtualisation = {
      # qemu
      kvmgt.enable = true;
      spiceUSBRedirection.enable = true;

      libvirtd = mkIf cfg.qemu.enable {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          ovmf = {
            enable = true;
            packages = [ pkgs.OVMFFull.fd ];
          };
          swtpm.enable = true;
        };
      };

      # podman
      podman = mkIf (cfg.docker.enable || cfg.podman.enable) {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings = {
          dns_enabled = true;
        };
        enableNvidia = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;
        autoPrune = {
          enable = true;
          flags = [ "--all" ];
          dates = "weekly";
        };
      };

      waydroid.enable = cfg.waydroid.enable;
      lxd.enable = cfg.waydroid.enable;
    };

    systemd.user = mkIf cfg.distrobox.enable {
      timers."distrobox-update" = {
        enable = true;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1h";
          OnUnitActiveSec = "1d";
          Unit = "distrobox-update.service";
        };
      };

      services."distrobox-update" = {
        enable = true;
        script = ''
          ${pkgs.distrobox}/bin/distrobox upgrade --all
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };
    };
  };
}
