{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;
  inherit (lib.secrets) mkSecret;

  rdomain = config.networking.domain;
  cfg = config.garden.services.mailserver;
in
{
  imports = [ inputs.simple-nixos-mailserver.nixosModules.default ];

  options.garden.services.mailserver = mkServiceOption "mailserver" { domain = "mail.${rdomain}"; };

  config = mkIf cfg.enable {
    garden.services = {
      nginx.enable = true;
      redis.enable = true;
      postgresql.enable = true;
    };

    age.secrets = {
      mailserver-isabel = mkSecret { file = "mailserver/isabel"; };
      mailserver-robin = mkSecret { file = "mailserver/robin"; };
      mailserver-vaultwarden = mkSecret { file = "mailserver/vaultwarden"; };
      mailserver-database = mkSecret { file = "mailserver/database"; };
      mailserver-grafana = mkSecret { file = "mailserver/grafana"; };
      mailserver-git = mkSecret { file = "mailserver/git"; };
      mailserver-noreply = mkSecret { file = "mailserver/noreply"; };
      mailserver-spam = mkSecret { file = "mailserver/spam"; };
    };

    # required for roundcube
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    mailserver = {
      enable = true;
      openFirewall = true;

      useFsLayout = true;
      vmailUserName = "vmail";
      vmailGroupName = "vmail";

      mailDirectory = "/srv/storage/mail/vmail";
      dkimKeyDirectory = "/srv/storage/mail/dkim";
      sieveDirectory = "/srv/storage/mail/sieve";

      # Enable STARTTLS
      enableImap = true;
      enableImapSsl = true;

      # eww
      enablePop3 = false;
      enablePop3Ssl = false;

      enableSubmission = false;
      enableSubmissionSsl = true;

      # Enable ManageSieve so that we don't need to change the config to update sieves
      enableManageSieve = true;

      # DKIM Settings
      dkimBodyCanonicalization = "relaxed";
      dkimHeaderCanonicalization = "relaxed";
      dkimKeyBits = 4096;
      dkimSelector = "mail";
      dkimSigning = true;

      hierarchySeparator = "/";
      localDnsResolver = false;
      fqdn = "${cfg.domain}";
      certificateScheme = "acme-nginx";
      domains = [ "${rdomain}" ];

      # Set all no-reply addresses
      rejectRecipients = [ "noreply@${rdomain}" ];

      loginAccounts = {
        "isabel@${rdomain}" = {
          hashedPasswordFile = config.age.secrets.mailserver-isabel.path;
          aliases = [
            "isabel"
            "isabelroses"
            "isabelroses@${rdomain}"
            "bell"
            "bell@${rdomain}"
            "me@${rdomain}"
            "admin"
            "admin@${rdomain}"
            "root"
            "root@${rdomain}"
            "postmaster"
            "postmaster@${rdomain}"
          ];
        };

        "robin@${rdomain}" = {
          hashedPasswordFile = config.age.secrets.mailserver-robin.path;
          aliases = [
            "robin"
            "robinwobin"
            "robinwobin@${rdomain}"
            "comfy"
            "comfy@${rdomain}"
            "comfysage"
            "comfysage@${rdomain}"
          ];
        };

        "git@${rdomain}" = {
          aliases = [
            "git"
            "git@${rdomain}"
          ];
          hashedPasswordFile = config.age.secrets.mailserver-git.path;
        };

        "vaultwarden@${rdomain}" = {
          aliases = [
            "vaultwarden"
            "bitwarden"
            "bitwarden@${rdomain}"
          ];
          hashedPasswordFile = config.age.secrets.mailserver-vaultwarden.path;
        };

        "grafana@${rdomain}" = {
          aliases = [
            "grafana"
            "monitor"
            "monitor@${rdomain}"
          ];
          hashedPasswordFile = config.age.secrets.mailserver-grafana.path;
        };

        "noreply@${rdomain}" = {
          aliases = [ "noreply" ];
          hashedPasswordFile = config.age.secrets.mailserver-noreply.path;
        };

        "spam@${rdomain}" = {
          aliases = [
            "spam"
            "shush"
            "shush@${rdomain}"
            "stfu"
            "stfu@${rdomain}"
          ];
          hashedPasswordFile = config.age.secrets.mailserver-spam.path;
        };
      };

      mailboxes = {
        Archive = {
          auto = "subscribe";
          specialUse = "Archive";
        };
        Drafts = {
          auto = "subscribe";
          specialUse = "Drafts";
        };
        Sent = {
          auto = "subscribe";
          specialUse = "Sent";
        };
        Junk = {
          auto = "subscribe";
          specialUse = "Junk";
        };
        Trash = {
          auto = "subscribe";
          specialUse = "Trash";
        };
      };

      fullTextSearch = {
        enable = true;
        # index new email as they arrive
        autoIndex = true;
        enforced = "body";
      };
    };

    services = {
      roundcube = {
        enable = true;

        package = pkgs.roundcube.withPlugins (
          plugins: builtins.attrValues { inherit (plugins) persistent_login carddav; }
        );

        # database = {
        #   host = "/run/postgresql";
        #   password = "";
        # };

        maxAttachmentSize = 50;

        dicts = [ pkgs.aspellDicts.en ];

        plugins = [
          "carddav"
          "persistent_login"
        ];

        # this is the url of the vhost, not necessarily the same as the fqdn of the mailserver
        hostName = "webmail.${rdomain}";
        extraConfig = ''
          $config['imap_host'] = array(
            'ssl://${config.mailserver.fqdn}' => "Isabelroses's Mail Server",
            'ssl://imap.gmail.com:993' => 'Google Mail',
          );
          $config['username_domain'] = array(
            '${config.mailserver.fqdn}' => '${rdomain}',
            'mail.gmail.com' => 'gmail.com',
          );
          $config['x_frame_options'] = false;
          # starttls needed for authentication, so the fqdn required to match
          # the certificate
          $config['smtp_host'] = "ssl://${config.mailserver.fqdn}";
          $config['smtp_user'] = "%u";
          $config['smtp_pass'] = "%p";
        '';
      };

      postfix = {
        dnsBlacklists = [
          "all.s5h.net"
          "b.barracudacentral.org"
          "bl.spamcop.net"
          "blacklist.woody.ch"
        ];

        dnsBlacklistOverrides = ''
          ${rdomain} OK
          ${config.mailserver.fqdn} OK
          127.0.0.0/8 OK
          10.0.0.0/8 OK
          192.168.0.0/16 OK
        '';

        config.smtp_hello_name = config.mailserver.fqdn;
      };

      phpfpm.pools.roundcube.settings = {
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
      };

      nginx.virtualHosts."webmail.${rdomain}" = {
        locations."/".extraConfig = lib.mkForce "";
      } // template.ssl rdomain;
    };
  };
}
