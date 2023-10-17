{lib, ...}: let
  inherit (lib) lists mapAttrsToList filterAttrs hasSuffix;

  primaryMonitor = config: builtins.elemAt config.modules.device.monitors 0;

  # filter files for the .nix suffix
  filterNixFiles = k: v: v == "regular" && hasSuffix ".nix" k;

  # import files that are selected by filterNixFiles
  importNixFiles = path:
    (lists.forEach (mapAttrsToList (name: _: path + ("/" + name))
        (filterAttrs filterNixFiles (builtins.readDir path))))
    import;

  # return an int based on boolean value
  boolToNum = bool:
    if bool
    then 1
    else 0;

  # a basic function to fetch a specified user's public keys from github .keys url
  fetchKeys = username: (builtins.fetchurl "https://github.com/${username}.keys");

  indexOf = list: elem: let
    f = f: i:
      if i == (builtins.length list)
      then null
      else if (builtins.elemAt list i) == elem
      then i
      else f f (i + 1);
  in
    f f 0;

  # a function to go from normal text to lower snake case
  # "A Normal String" -> "a-normal-string"
  serializeTheme = inputString: lib.strings.toLower (builtins.replaceStrings [" "] ["-"] inputString);

  # a function that checks if a list contains a list of given strings
  containsStrings = {
    list,
    targetStrings,
  }:
    builtins.all (s: builtins.any (x: x == s) list) targetStrings;

  # the following are quick checks to find if they meet the criteria with less repetion
  # takes config and a list of accepted device types
  isAcceptedDevice = conf: acceptedTypes: builtins.elem conf.modules.device.type acceptedTypes;

  # if the device is wayland by checking video and isWayland options
  isWayland = conf: conf.modules.system.video.enable && conf.modules.usrEnv.isWayland;

  # check if modernshell and cli are both enabled
  isModernShell = conf: conf.modules.programs.cli.enable && conf.modules.programs.cli.modernShell.enable;
in {
  inherit primaryMonitor filterNixFiles importNixFiles boolToNum fetchKeys containsStrings serializeTheme isAcceptedDevice isWayland isModernShell indexOf;
}
