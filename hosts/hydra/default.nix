{ pkgs, ... }:
{
  imports = [ ./hardware.nix ];

  config.garden = {
    device = {
      type = "hybrid";
      cpu = "intel";
      gpu = null;
      monitors = [ "eDP-1" ];
      hasTPM = true;
      hasBluetooth = true;
      hasSound = true;
    };

    system = {
      mainUser = "isabel";

      boot = {
        loader = "systemd-boot";
        secureBoot = false;
        tmpOnTmpfs = false;
        loadRecommendedModules = true;
        enableKernelTweaks = true;
        initrd.enableTweaks = true;
        plymouth.enable = false;
      };

      fs = [
        "btrfs"
        "vfat"
      ];
      video.enable = true;
      sound.enable = true;
      bluetooth.enable = false;
      printing.enable = false;
      yubikeySupport.enable = true;

      security = {
        fixWebcam = false;
        auditd.enable = true;
      };

      networking = {
        optimizeTcp = true;

        wirelessBackend = "iwd";

        tailscale = {
          enable = false;
          isClient = true;
        };
      };

      virtualization = {
        enable = true;
        docker.enable = true;
        qemu.enable = false;
        podman.enable = false;
        distrobox.enable = false;
      };
    };

    environment = {
      desktop = "Hyprland";
      useHomeManager = true;
    };

    programs = {
      agnostic.git.signingKey = "7AFB9A49656E69F7";

      cli = {
        enable = true;
        modernShell.enable = true;
      };

      tui.enable = true;

      gui = {
        enable = true;

        kdeconnect = {
          enable = false;
          indicator.enable = true;
        };

        terminals.kitty.enable = true;

        zathura.enable = true;
      };
    };

    services = {
      dev.vscode-server.enable = true;
      networking.cloudflared.enable = true;
    };
  };

  config.services.mediawiki = {
    enable = true;
    passwordFile = "/etc/mediawikipwd";

    name = "Catppuccin Wiki";

    extensions = {
      # some extensions are included and can enabled by passing null
      VisualEditor = null;

      Highlightjs_Integration = pkgs.fetchzip {
        url = "https://github.com/Nicolas01/Highlightjs_Integration/archive/master.zip";
        # hash = "sha256-0000000000000000000000000000000000000000000=";
        hash = "sha256-GNE1z/gw2TmLOW+2k+20fhwurzOEfhqCfq3NxIeNzVY=";
      };

      Mermaid = "/var/lib/mediawiki/Mermaid";
    };

    extraConfig = ''
      $wgFavicon = "https://raw.githubusercontent.com/catppuccin/website/2024/public/favicon.png";
      $wgLogos = ['icon' => "https://raw.githubusercontent.com/catppuccin/website/2024/public/favicon.png"];

      # set out own license
      # $wgRightsPage = "Project:About";
      $wgRightsIcon = "";
      $wgRightsText = "CC-BY-4.0 International License";
      $wgRightsUrl = "https://github.com/catppuccin/community/blob/main/LICENSE";

      # Disable anonymous editing
      $wgGroupPermissions['*']['createpage'] = false;
      $wgGroupPermissions['*']['createtalk'] = false;
      $wgGroupPermissions['*']['edit'] = false;
      $wgGroupPermissions['*']['writeapi'] = false;

      # prevent people from creating accounts and just editing anything
      unset($wgGroupPermissions['user']);

      # create a new group
      $wgGroupPermissions['maintainer'];
      # $wgGroupPermissions['maintainer']['createpage'] = true;
      $wgGroupPermissions['maintainer']['edit'] = true;
      $wgGroupPermissions['maintainer']['minoredit'] = true;
      $wgGroupPermissions['maintainer']['writeapi'] = true;
      $wgGroupPermissions['maintainer']['upload'] = true;
      $wgGroupPermissions['maintainer']['reupload'] = true;

      # regive admin perms
      $wgGroupPermissions['sysop']['createpage'] = true;
      $wgGroupPermissions['sysop']['edit'] = true;
      $wgGroupPermissions['sysop']['minoredit'] = true;
      $wgGroupPermissions['sysop']['writeapi'] = true;
      $wgGroupPermissions['sysop']['changetags'] = true;
      $wgGroupPermissions['sysop']['move'] = true;
      $wgGroupPermissions['sysop']['movefile'] = true;
      $wgGroupPermissions['sysop']['move-categorypages'] = true;
      $wgGroupPermissions['sysop']['move-subpages'] = true;
      $wgGroupPermissions['sysop']['move-rootuserpages'] = true;
      $wgGroupPermissions['sysop']['upload'] = true;
      $wgGroupPermissions['sysop']['reupload'] = true;
      $wgGroupPermissions['sysop']['reupload-shared'] = true;
      $wgGroupPermissions['sysop']['sendemail'] = true;

      # remove the powered by mediawiki icon
      unset($wgFooterIcons['poweredby']);
    '';

    # TODO: read this later
    # https://www.mediawiki.org/wiki/Manual:Preventing_access
    # https://www.mediawiki.org/wiki/Manual:User_rights

    webserver = "nginx";
    nginx.hostName = "ctp-wiki.isabelroses.com";
  };
}
