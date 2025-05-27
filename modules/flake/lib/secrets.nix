{ inputs }:
let
  inherit (inputs) self;

  /**
    Create secrets for use with `agenix`.

    # Arguments

    - [file] the age file to use for the secret
    - [mode] the permissions of the secret, this defaults to "400"

    # Type

    ```
    mkUserSecret :: (String -> String -> String -> String) -> AttrSet
    ```

    # Example

    ```nix
    mkUserSecret { file = "./my-secret.age"; }
    => {
      file = "./my-secret.age";
      mode = "400";
    }
    ```
  */
  mkUserSecret =
    {
      file,
      mode ? "400",
      ...
    }@args:
    let
      args' = builtins.removeAttrs args [
        "file"
        "mode"
      ];
    in
    {
      file = "${self}/secrets/${file}.age";
      inherit mode;
    }
    // args';

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
      mode ? "400",
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
      file = "${self}/secrets/${file}.age";
      inherit owner group mode;
    }
    // args';
in
{
  inherit mkUserSecret mkSystemSecret;
}
