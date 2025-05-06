{ lib, ... }:
let
  inherit (lib)
    getAttrFromPath
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
    check if a predicate for any user config is true

    # Arguments

    - [conf] the configuration that nixosConfigurations provides
    - [cond] predicate function to check against config variable

    # Type

    ```
    anyHome :: AttrSet -> (Any -> Bool) -> Bool
    ```

    # Example

    ```nix
    anyHome config (cfg: cfg.programs.hyprland.enable)
    => true
    ```
  */
  anyHome =
    conf: cond:
    let
      list = map (
        user:
        getAttrFromPath [
          "home-manager"
          "users"
          user
        ] conf
      ) conf.garden.system.users;
    in
    any cond list;
in
{
  inherit
    ifTheyExist
    anyHome
    ;
}
