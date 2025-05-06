{
  lib,
  _class,
  config,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) str;

  sys = config.garden.system;
in
{
  options.garden.environment.flakePath = mkOption {
    type = str;
    default = "/${if (_class == "nixos") then "home" else "Users"}/${sys.mainUser}/.config/flake";
    description = "The path to the configuration";
  };

  config.environment.variables = {
    SYSTEMD_PAGERSECURE = "true";

    # Some programs like `nh` use the FLAKE env var to determine the flake path
    FLAKE = config.garden.environment.flakePath;
    NH_FLAKE = config.garden.environment.flakePath;
  };
}
