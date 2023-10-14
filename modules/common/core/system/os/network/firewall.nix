{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkDefault mkForce;
  inherit (config.modules) device;
in {
  environment.etc."fail2ban/filter.d/vaultwarden.conf" = {
    enable = config.services.vaultwarden.enable;
    text = ''
      [INCLUDES]
      before = common.conf
      [Definition]
      failregex = ^.*Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$
      ignoreregex =
    '';
  };

  environment.etc."fail2ban/filter.d/vaultwarden-admin.conf" = {
    enable = config.services.vaultwarden.enable;
    text = ''
      [INCLUDES]
      before = common.conf
      [Definition]
      failregex = ^.*Invalid admin token\. IP: <ADDR>.*$
      ignoreregex =
    '';
  };

  services = {
    # enable opensnitch firewall
    # inactive until opensnitch UI is opened
    opensnitch.enable = true;

    # fail2ban firewall jail
    fail2ban = {
      enable = true;
      banaction = "iptables-multiport[blocktype=DROP]";
      maxretry = 7;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "192.168.86.0/16"
      ];

      jails = mkDefault {
        sshd = ''
          enabled = true
          port = 22
          mode = aggressive
        '';

        vaultwarden = ''
          enabled = true
          port = 80,443,8822
          filter = vaultwarden
          banaction = %(banaction_allports)s
          logpath = /var/log/vaultwarden.log
          maxretry = 3
          bantime = 14400
          findtime = 14400
        '';
        vaultwarden-admin = ''
          enabled = true
          port = 80,443
          filter = vaultwarden-admin
          banaction = %(banaction_allports)s
          logpath = /var/log/vaultwarden.log
          maxretry = 3
          bantime = 14400
          findtime = 14400
        '';
      };

      bantime-increment = {
        enable = true;
        rndtime = "12m";
        overalljails = true;
        multipliers = "4 8 16 32 64 128 256 512 1024";
        maxtime = "48h";
      };
    };
  };
  networking = {
    nftables.enable = false;
    firewall = {
      enable = mkDefault true;
      package = mkDefault pkgs.iptables-nftables-compat;
      allowedTCPPorts = [
        443
        8080
      ];
      allowedUDPPorts = [];
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } #KDEconnect
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } #KDEconnect
      ];
      allowPing = mkDefault device.type == "server";
      logReversePathDrops = true;
      logRefusedConnections = mkDefault false;
      checkReversePath = mkForce false; # Don't filter DHCP packets, according to nixops-libvirtd
    };
  };
}
