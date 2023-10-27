_: let
  # check if the host platform is linux and x86
  # (isx86Linux pkgs) -> true
  isx86Linux = pkgs: with pkgs.stdenv; hostPlatform.isLinux && hostPlatform.isx86;

  # assume the first monitor in the list of monitors is primary
  # get its name from the list of monitors
  # `primaryMonitor osConfig` -> "DP-1"
  primaryMonitor = config: builtins.elemAt config.modules.device.monitors 0;
in {
  inherit isx86Linux primaryMonitor;
}
