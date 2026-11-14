{ lib }:
let
  inherit (lib.strings) concatStringsSep;

  /**
    The ports a web jail bans on. quic is on, so a tcp-only ban leaves http/3
    open

    # Type

    ```
    web :: AttrSet
    ```
  */
  web = {
    port = "http,https";
    protocol = "tcp,udp";
  };

  /**
    A fail2ban jail that reads a systemd unit's journal and bans on its web
    ports

    # Arguments

    - [unit]: The systemd unit, without `.service`
    - [regexes]: The failregexes, matched against each journal line
    - [settings]: Extra jail settings, these override the defaults

    # Type

    ```
    journalJail :: String -> [String] -> AttrSet -> AttrSet
    ```
  */
  journalJail = unit: regexes: settings: {
    filter.Definition = {
      # fail2ban only reads extra regexes from indented continuation lines
      failregex = concatStringsSep "\n    " regexes;
      ignoreregex = "";
    };
    settings = web // { journalmatch = "_SYSTEMD_UNIT=${unit}.service"; } // settings;
  };
in
{
  inherit web journalJail;
}
