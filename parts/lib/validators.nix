{ lib, ... }:
let
  # a function that will append a list of groups if they exist in config.users.groups
  ifTheyExist =
    config: groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  # a function that returns a boolean based on whether or not the groups exist
  ifGroupsExist = config: groups: lib.any (group: builtins.hasAttr group config.users.groups) groups;

  # convenience function check if the declared device type is of an accepted type
  # takes config and a list of accepted device types
  # `isAcceptedDevice osConfig ["foo" "bar"];`
  isAcceptedDevice = conf: list: builtins.elem conf.modules.device.type list;

  # assert if the device is wayland-ready by checking sys.video and env.isWayland options
  # `(lib.isWayland config)` where config is in scope
  # `isWayland osConfig` -> true
  isWayland = conf: conf.modules.environment.desktop != null && conf.modules.environment.isWayland;

  # ifOneEnabled takes a parent option and 3 child options and checks if at least one of them is enabled
  # `ifOneEnabled config.modules.services "service1" "service2" "service3"`
  ifOneEnabled =
    cfg: a: b: c:
    (cfg.a || cfg.b || cfg.c);

  # check if modernshell and cli are both enabled
  isModernShell =
    conf: conf.modules.programs.cli.enable && conf.modules.programs.cli.modernShell.enable;
in
{
  inherit
    ifTheyExist
    ifGroupsExist
    isAcceptedDevice
    isWayland
    ifOneEnabled
    isModernShell
    ;
}
