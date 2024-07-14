{ lib }:
let
  inherit (lib)
    lists
    filesystem
    mapAttrsToList
    filterAttrs
    hasSuffix
    ;

  # filter files for the .nix suffix
  filterNixFiles = k: v: v == "regular" && hasSuffix ".nix" k;

  # import files that are selected by filterNixFiles
  importNixFiles =
    path:
    (lists.forEach (
      mapAttrsToList (name: _: path + ("/" + name)) (filterAttrs filterNixFiles (builtins.readDir path))
    ))
      import;

  # import all nix files and directories
  importNixFilesAndDirs =
    dir: lists.filter (f: f != "default.nix") (filesystem.listFilesRecursive dir);

  # return an int based on boolean value
  boolToNum = bool: if bool then 1 else 0;

  # convert a list of integers to a list of string
  # `intListToStringList [1 2 3]` -> ["1" "2" "3"]
  intListToStringList = list: map (toString list);
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

  # a function that checks if a list contains a list of given strings
  containsStrings =
    { list, targetStrings }: builtins.all (s: builtins.any (x: x == s) list) targetStrings;
in
{
  inherit
    filterNixFiles
    importNixFiles
    importNixFilesAndDirs
    boolToNum
    containsStrings
    indexOf
    intListToStringList
    ;
}
