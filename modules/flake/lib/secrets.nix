{ inputs }:
let
  inherit (inputs) self;

  /**
    Create secrets for use with `agenix`.

    # Arguments

    - [file] the age file to use for the secret
    - [owner] the owner of the secret, this defaults to "root"
    - [group] the group of the secret, this defaults to "root"
    - [mode] the permissions of the secret, this defaults to "400"

    # Type

    ```
    mkSystemSecret :: (String -> String -> String -> String) -> AttrSet
    ```

    # Example

    ```nix
    mkSystemSecret { file = "./my-secret.age"; }
    => {
      file = "./my-secret.age";
      owner = "root";
      group = "root";
      mode = "400";
    }
    ```
  */
  mkSystemSecret =
    {
      file,
      owner ? "root",
      group ? "root",
      mode ? "0400",
      ...
    }@args:
    let
      args' = builtins.removeAttrs args [
        "file"
        "owner"
        "group"
        "mode"
      ];
    in
    {
      sopsFile = "${self}/secrets/services/${file}.yaml";
      inherit owner group mode;
    }
    // args';
in
{
  inherit mkSystemSecret;
}
