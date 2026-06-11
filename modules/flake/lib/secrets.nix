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
