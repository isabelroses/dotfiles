{ lib, ... }:
let
  inherit (lib.attrsets) getAttrFromPath;
  inherit (lib.trivial) flip;

  inherit (builtins)
    elem
    filter
    hasAttr
    any
    ;

  /**
    a function that will append a list of groups if they exist in config.users.groups

    # Arguments

    - [config] the configuration that nixosConfigurations provides
    - [groups] a list of groups to check for

    # Type

    ```
    ifTheyExist :: AttrSet -> List -> List
    ```

    # Example

    ```nix
    ifTheyExist config ["wheel" "users"]
    => ["wheel"]
    ```
  */
  ifTheyExist = config: groups: filter (group: hasAttr group config.users.groups) groups;

  /**
    convenience function check if the declared device type is of an accepted type

    # Arguments

    - [config] the configuration that nixosConfigurations provides
    - [list] a list of devices that will be accepted

    # Type

    ```
    hasProfile :: AttrSet -> List -> Bool
    ```

    # Example

    ```nix
    hasProfile osConfig ["foo" "bar"]
    => false
    ```
  */
  hasProfile = conf: list: any (flip elem conf.garden.device.profiles) list;

  /**
    check if the device is wayland-ready

    # Arguments

    - [config] the configuration that nixosConfigurations provides

    # Type

    ```
    isWayland :: AttrSet -> Bool
    ```

    # Example

    ```nix
    isWayland osConfig
    => true
    ```
  */
  isWayland = conf: conf.garden.meta.isWayland;

  /**
    check if the device is modernShell-ready

    # Arguments

    - [config] the configuration that nixosConfigurations provides

    # Type

    ```
    isModernShell :: AttrSet -> Bool
    ```

    # Example

    ```nix
    isModernShell osConfig
    => true
    ```
  */
  isModernShell =
    conf: conf.garden.programs.cli.enable && conf.garden.programs.cli.modernShell.enable;

  /**
    check if a predicate for any user config is true

    # Arguments

    - [conf] the configuration that nixosConfigurations provides
    - [cond] predicate function to check against config variable
    - [path] attr path to the config variable

    # Type

    ```
    anyHome :: AttrSet -> (Any -> Bool) -> List -> Bool
    ```

    # Example

    ```nix
    anyHome config (cfg: cfg.enable && cfg.modernShell.enable) [ "garden" "programs" "cli" ]
    => true
    ```
  */
  anyHome =
    conf: cond: path:
    let
      list = map (
        user:
        getAttrFromPath (
          [
            "home-manager"
            "users"
            user
          ]
          ++ path
        ) conf
      ) conf.garden.system.users;
    in
    any cond list;
in
{
  inherit
    ifTheyExist
    hasProfile
    isWayland
    isModernShell
    anyHome
    ;
}
