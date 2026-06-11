{ lib }:
let
  /**
    Create git url aliases for a given domain

    # Arguments

    - [domain] the domain to create the alias for
    - [alias] the alias to use
    - [user] the user to use, this defaults to "git"
    - [port] the port to use, this is optional

    # Type

    ```
    giturl :: (String -> String -> String -> Int) -> AttrSet
    ```

    # Example

    ```nix
    giturl { domain = "github.com"; alias = "gh"; }
    => {
      "https://github.com/".insteadOf = "gh:";
      "ssh://git@github.com/".pushInsteadOf = "gh:";
    }
    ```
  */
  giturl =
    {
      domain,
      alias,
      user ? "git",
      port ? null,
      ...
    }:
    {
      "https://${domain}/".insteadOf = "${alias}:";
      "ssh://${user}@${domain}${
        if (port == null) then
          ""
        else if (builtins.isInt port) then
          ":" + (toString port)
        else
          ":" + port
      }/".pushInsteadOf =
        "${alias}:";
    };

  /**
    Create a public key for a given host

    # Arguments

    - [host] the host to create the public key for
    - [key] this is a attrset with the key type and key

    # Type

    ```
    mkPub :: (String -> AttrSet -> AttrSet) -> String -> AttrSet -> AttrSet
    ```

    # Example

    ```nix
    mkPub "github.com" {
      type = "rsa";
      key = "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
    }
    => {
      "github.com-rsa" = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
      };
    }
    ```
  */
  mkPub = host: key: {
    "${host}-${key.type}" = {
      hostNames = [ host ];
      publicKey = "ssh-${key.type} ${key.key}";
    };
  };

  /**
    Create public keys for a given host

    # Arguments

    - [host] the host to create the public keys for
    - [keys] the list of keys to create

    # Type

    ```
    mkPubs :: (String -> List) -> String -> List -> AttrSet
    ```

    # Example

    ```nix
    mkPubs "github.com" [
      {
        type = "rsa";
        key = "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
      }
      {
        type = "ed25519";
        key = "AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      }
    ]
    => {
      "github.com-ed25519" = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
      "github.com-rsa" = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
      };
    }
    ```
  */
  mkPubs = host: keys: lib.foldl' (acc: key: acc // mkPub host key) { } keys;
in
{
  inherit
    mkPub
    mkPubs
    giturl
    ;
}
