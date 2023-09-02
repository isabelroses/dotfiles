{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (config.networking) domain;
  cfg = config.modules.usrEnv.services.mailserver;
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  config = lib.mkIf cfg.enable {
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
        hostName = "webmail.${domain}";
        extraConfig = ''
          $config['imap_host'] = array(
            'tls://mail.${domain}' => "Isabelroses's Mail Server",
            'ssl://imap.gmail.com:993' => 'Google Mail',
          );
          $config['username_domain'] = array(
            'mail.${domain}' => '${domain}',
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
          ${domain} OK
          mail.${domain} OK
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
      fqdn = "mail.${domain}";
      certificateScheme = "acme-nginx";
      domains = ["${domain}"];
      loginAccounts = {
        "isabel@${domain}" = {
          hashedPasswordFile = config.sops.secrets.mailserver-isabel.path;
          aliases = ["isabel" "bell" "bell@${domain}" "me@${domain}" "admin" "admin@${domain}" "root" "root@${domain}" "postmaster" "postmaster@${domain}"];
        };

        "gitea@${domain}" = {
          aliases = ["gitea"];
          hashedPasswordFile = config.sops.secrets.mailserver-gitea.path;
        };

        "vaultwarden@${domain}" = {
          aliases = ["vaultwarden" "bitwarden" "bitwarden@${domain}"];
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
