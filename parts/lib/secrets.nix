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
    mkSecret :: (String -> String -> String -> String) -> AttrSet
    ```

    # Example

    ```nix
    mkSecret { file = "./my-secret.age"; }
    => {
      file = "./my-secret.age";
      owner = "root";
      group = "root";
      mode = "400";
    }
    ```
  */
  mkSecret =
    {
      file,
      owner ? "root",
      group ? "root",
      mode ? "400",
      ...
    }:
    {
      file = "${self}/secrets/${file}.age";
      inherit owner group mode;
    };

  /**
    A light wrapper around mkSecret that allows you to specify the output path

    # Arguments

    - [file] the age file to use for the secret
    - [owner] the owner of the secret, this defaults to "root"
    - [group] the group of the secret, this defaults to "root"
    - [mode] the permissions of the secret, this defaults to "400"
    - [path] the path to output the secret to

    # Type

    ```
    mkSecretWithPath :: (String -> String -> String -> String -> String) -> AttrSet
    ```

    # Example

    ```nix
    mkSecret { file = "./my-secret.age"; path = "/etc/my-secret"; }
    => {
      file = "./my-secret.age";
      path = "/etc/my-secret";
      owner = "root";
      group = "root";
      mode = "400";
    }
    ```
  */
  mkSecretWithPath =
    {
      file,
      path,
      owner ? "root",
      group ? "root",
      mode ? "400",
      ...
    }:
    mkSecret {
      inherit
        file
        owner
        group
        mode
        ;
    }
    // {
      inherit path;
    };
in
{
  inherit mkSecret mkSecretWithPath;
}
