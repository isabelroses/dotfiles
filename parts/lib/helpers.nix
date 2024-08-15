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
    giturl { domain = "github.com", alias = "gh"; }
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
      }/".pushInsteadOf = "${alias}:";
    };
in
{
  inherit
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
