_: let
  # check if the host platform is linux and x86
  # (isx86Linux pkgs) -> true
  isx86Linux = pkgs: with pkgs.stdenv; hostPlatform.isLinux && hostPlatform.isx86;

  # ldTernary, short for linux darwin ternary, is a ternary operator that takes 3 arguments
  # the pkgs used to determine the standard environment, l: the linux result, d: the darwin result
  # https://github.com/nekowinston/dotfiles/blob/36f7f4a86af4d1ecd3d2da483585e4d2503a978a/machines/lib.nix#L32
  ldTernary = pkgs: l: d:
    if pkgs.stdenv.isLinux
    then l
    else if pkgs.stdenv.isDarwin
    then d
    else throw "Unsupported system: ${pkgs.stdenv.system}";

  # assume the first monitor in the list of monitors is primary
  # get its name from the list of monitors
  # `primaryMonitor osConfig` -> "DP-1"
  primaryMonitor = config: builtins.elemAt config.modules.device.monitors 0;
in {
  inherit isx86Linux primaryMonitor ldTernary;
}
