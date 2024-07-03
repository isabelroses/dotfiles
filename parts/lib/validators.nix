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
  isAcceptedDevice = conf: list: builtins.elem conf.garden.device.type list;

  # assert if the device is wayland-ready by checking sys.video and env.isWayland options
  # `(lib.isWayland config)` where config is in scope
  # `isWayland osConfig` -> true
  isWayland = conf: conf.garden.environment.desktop != null && conf.garden.environment.isWayland;

  # ifOneEnabled takes a parent option and 3 child options and checks if at least one of them is enabled
  # `ifOneEnabled config.garden.services "service1" "service2" "service3"`
  ifOneEnabled =
    cfg: a: b: c:
    (cfg.a || cfg.b || cfg.c);

  # check if modernshell and cli are both enabled
  isModernShell =
    conf: conf.garden.programs.cli.enable && conf.garden.programs.cli.modernShell.enable;
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
