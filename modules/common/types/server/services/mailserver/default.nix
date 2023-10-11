{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  device = config.modules.device;
  cfg = config.modules.services.mailserver;
  acceptedTypes = ["server" "hybrid"];
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  config = mkIf (builtins.elem device.type acceptedTypes && cfg.enable) {
    # required for roundcube
    networking.firewall.allowedTCPPorts = [80 443];

    services = {
      roundcube = {
        enable = true;
        database.username = "roundcube";
        maxAttachmentSize = 50;
        dicts = with pkgs.aspellDicts; [en];
        # this is the url of the vhost, not necessarily the same as the fqdn of
        # the mailserver
        hostName = "webmail.isabelroses.com";
        extraConfig = ''
          $config['imap_host'] = array(
            'tls://mail.isabelroses.com' => "Isabelroses's Mail Server",
            'ssl://imap.gmail.com:993' => 'Google Mail',
          );
          $config['username_domain'] = array(
            'mail.isabelroses.com' => 'isabelroses.com',
            'mail.gmail.com' => 'gmail.com',
          );
          $config['x_frame_options'] = false;
          # starttls needed for authentication, so the fqdn required to match
          # the certificate
          $config['smtp_host'] = "tls://${config.mailserver.fqdn}";
          $config['smtp_user'] = "%u";
          $config['smtp_pass'] = "%p";
          $config['plugins'] = [ "carddav" ];
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
          isabelroses.com OK
          mail.isabelroses.com OK
          127.0.0.0/8 OK
          192.168.0.0/16 OK
        '';
        headerChecks = [
          {
            action = "IGNORE";
            pattern = "/^User-Agent.*Roundcube Webmail/";
          }
        ];

        config = {
          smtp_helo_name = config.mailserver.fqdn;
        };
      };

      phpfpm.pools.roundcube.settings = {
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
      };
    };

    mailserver = {
      enable = true;
      mailDirectory = "/srv/storage/mail/vmail";
      dkimKeyDirectory = "/srv/storage/mail/dkim";
      sieveDirectory = "/srv/storage/mail/sieve";
      openFirewall = true;
      enableImap = true;
      enableImapSsl = true;
      enablePop3 = false;
      enablePop3Ssl = false;
      enableSubmission = false;
      enableSubmissionSsl = true;
      hierarchySeparator = "/";
      localDnsResolver = false;
      fqdn = "mail.isabelroses.com";
      certificateScheme = "acme-nginx";
      domains = ["isabelroses.com"];
      loginAccounts = {
        "isabel@isabelroses.com" = {
          hashedPasswordFile = config.sops.secrets.mailserver-isabel.path;
          aliases = ["isabel" "me@isabelroses.com" "admin" "admin@isabelroses.com" "root" "root@isabelroses.com" "postmaster" "postmaster@isabelroses.com"];
        };

        "gitea@isabelroses.com" = {
          aliases = ["gitea"];
          hashedPasswordFile = config.sops.secrets.mailserver-gitea.path;
        };

        "vaultwarden@isabelroses.com" = {
          aliases = ["vaultwarden"];
          hashedPasswordFile = config.sops.secrets.mailserver-vaultwarden.path;
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
        # this only applies to plain text attachments, binary attachments are never indexed
        indexAttachments = true;
        enforced = "body";
      };
    };
  };
}
