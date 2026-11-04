{ inputs }:
let
  inherit (inputs) self;

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
in
{
  inherit mkSecret;
}
