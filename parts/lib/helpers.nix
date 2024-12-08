{ lib }:
let
  inherit (lib.lists) forEach filter;
  inherit (lib.attrsets) filterAttrs mapAttrsToList;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;

  /**
    filter files for the .nix suffix

    # Arguments

    - [k] they key, which is the file name
    - [v] the value, which is the type of the file

    # Type

    ```
    filterNixFiles :: String -> String -> Bool
    ```

    # Example

    ```nix
    filterNixFiles "default.nix" "regular"
    => true
    ```
  */
  filterNixFiles = k: v: v == "regular" && hasSuffix ".nix" k;

  /**
    Import all file that filterNixFiles allows for

    # Arguments

    - [path] the path to the directory

    # Type

    ```
    importNixFiles :: String -> List
    ```

    # Example

    ```nix
    importNixFiles ./.
    => [ {...} ]
    ```
  */
  importNixFiles =
    path:
    (forEach (
      mapAttrsToList (name: _: path + ("/" + name)) (filterAttrs filterNixFiles (builtins.readDir path))
    ))
      import;

  /**
    import all nix files and directories

    # Arguments

    - [dir] the directory to search for nix files

    # Type

    ```
    importNixFilesAndDirs :: String -> List
    ```

    # Example

    ```nix
    importNixFilesAndDirs ./.
    => [ "flake.nix" ]
    ```
  */
  importNixFilesAndDirs = dir: filter (f: f != "default.nix") (listFilesRecursive dir);

  /**
    return an int based on boolean value

    # Arguments

    - [bool] the boolean value

    # Type

    ```
    boolToNum :: Bool -> Int
    ```

    # Example

    ```nix
    boolToNum true
    => 1
    ```
  */
  boolToNum = bool: if bool then 1 else 0;

  /**
    convert a list of integers to a list of string

    # Arguments

    - [list] the list of integers

    # Type

    ```
    intListToStringList :: List -> List
    ```

    # Example

    ```nix
    intListToStringList [1 2 3]
    => ["1" "2" "3"]
    ```
  */
  intListToStringList = list: map (toString list);

  /**
    a function that returns the index of an element in a list

    # Arguments

    - [list] the list to search in
    - [elem] the element to search for

    # Type

    ```
    indexOf :: List -> Any -> Int
    ```

    # Example

    ```nix
    indexOf [1 2 3] 2
    => 1
    ```
  */
  indexOf =
    list: elem:
    let
      f =
        f: i:
        if i == (builtins.length list) then
          null
        else if (builtins.elemAt list i) == elem then
          i
        else
          f f (i + 1);
    in
    f f 0;

  /**
    a function that checks if a list contains a list of given strings

    # Arguments

    - [list] the list to search in
    - [targetStrings] the list of strings to search for

    # Type

    ```
    containsStrings :: List -> List -> Bool
    ```

    # Example

    ```nix
    containsStrings ["a" "b" "c"] ["a" "b"]
    => true
    ```
  */
  containsStrings =
    list: targetStrings: builtins.all (s: builtins.any (x: x == s) list) targetStrings;

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
        if (builtins.isNull port) then
          ""
        else if (builtins.isInt port) then
          ":" + (builtins.toString port)
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
    filterNixFiles
    importNixFiles
    importNixFilesAndDirs
    boolToNum
    containsStrings
    indexOf
    intListToStringList
    ;
}
