{ lib }:
let
  inherit (lib.lists) forEach filter;
  inherit (lib.attrsets) filterAttrs mapAttrsToList;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;

  # filter files for the .nix suffix
  filterNixFiles = k: v: v == "regular" && hasSuffix ".nix" k;

  # import files that are selected by filterNixFiles
  importNixFiles =
    path:
    (forEach (
      mapAttrsToList (name: _: path + ("/" + name)) (filterAttrs filterNixFiles (builtins.readDir path))
    ))
      import;

  # import all nix files and directories
  importNixFilesAndDirs = dir: filter (f: f != "default.nix") (listFilesRecursive dir);

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
