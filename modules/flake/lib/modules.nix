# what service modules call: their garden.services entry, sops secrets and
# fail2ban jails
{ lib, inputs }:
let
  inherit (inputs) self;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkOptionDefault;
  inherit (lib.strings) concatStringsSep;

  /**
    A module declaring a garden service and its defaults, for a service
    module's imports. The defaults are mkOptionDefault, so anything a host
    sets wins, and they hold while the service is disabled.

    # Arguments

    - [name]: The name of the service
    - [defaults]: Its defaults, e.g. `{ port = 3033; }`

    # Type

    ```
    mkService :: String -> AttrSet -> Module
    ```
  */
  mkService = name: defaults: {
    garden.services.${name} = mapAttrs (_: mkOptionDefault) defaults;
  };

  /**
    Create a `sops.secrets` entry for a file in `secrets/services/`.

    # Arguments

    - [file] the name of the sops file, without `secrets/services/` or `.yaml`
    - every other attribute (`key`, `owner`, `mode`, …) is passed through to
      `sops.secrets.<name>` unchanged

    # Type

    ```
    mkSecret :: { file :: String, ... } -> AttrSet
    ```

    # Example

    ```nix
    mkSecret { file = "borg"; key = "forgejo-passphrase"; }
    => {
      sopsFile = "${self}/secrets/services/borg.yaml";
      key = "forgejo-passphrase";
    }
    ```
  */
  mkSecret =
    {
      file,
      ...
    }@args:
    let
      args' = removeAttrs args [ "file" ];
    in
    {
      sopsFile = "${self}/secrets/services/${file}.yaml";
    }
    // args';

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
  inherit
    mkService
    mkSecret
    web
    journalJail
    ;
}
