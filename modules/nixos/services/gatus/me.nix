[
  # web
  {
    name = "website";
    group = "web";
    url = "https://isabelroses.com";
  }

  # dev
  {
    name = "forgejo";
    group = "dev";
    url = "https://git.isabelroses.com";
  }
  {
    name = "atuin";
    group = "dev";
    url = "https://atuin.isabelroses.com";
  }
  {
    name = "wakapi";
    group = "dev";
    url = "https://wakapi.isabelroses.com";
  }

  # apps
  {
    name = "vaultwarden";
    group = "apps";
    url = "https://vault.isabelroses.com/alive";
  }
  {
    name = "kanidm";
    group = "apps";
    url = "https://sso.isabelroses.com";
  }
  {
    name = "immich";
    group = "apps";
    url = "https://photos.isabelroses.com/api/server/ping";
    conditions = [ "[BODY].res == pong" ];
  }
  {
    name = "jellyfin";
    group = "apps";
    url = "https://tv.isabelroses.com/health";
  }
  {
    name = "bookmark";
    group = "apps";
    url = "https://bookmark.isabelroses.com";
  }
  {
    name = "analytics";
    group = "apps";
    url = "https://analytics.isabelroses.com";
  }

  # social
  {
    name = "akkoma";
    group = "social";
    url = "https://akko.isabelroses.com/api/v1/instance";
  }
  {
    name = "matrix";
    group = "social";
    url = "https://matrix.isabelroses.com/_matrix/client/versions";
  }
  {
    name = "tranquil pds";
    group = "social";
    url = "https://pds.isabelroses.com/xrpc/_health";
  }

  # mail
  {
    name = "webmail";
    group = "mail";
    url = "https://webmail.isabelroses.com";
  }
  {
    name = "imap";
    group = "mail";
    url = "tcp://mail.isabelroses.com:993";
    defaultConditions = false;
    conditions = [ "[CONNECTED] == true" ];
  }
  {
    name = "smtp";
    group = "mail";
    url = "tls://mail.isabelroses.com:465";
    defaultConditions = false;
    conditions = [
      "[CONNECTED] == true"
      "[CERTIFICATE_EXPIRATION] > 48h"
    ];
  }
]
