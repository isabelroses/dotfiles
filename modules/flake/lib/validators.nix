{ lib, ... }:
let
  inherit (lib.attrsets) getAttrFromPath;
  inherit (lib.lists) any;

  /**
    check if a predicate for any user config is true

    # Arguments

    - [conf] the configuration that nixosConfigurations provides
    - [cond] predicate checked against each user's home-manager config

    # Type

    ```
    anyHome :: AttrSet -> (AttrSet -> Bool) -> Bool
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
  inherit anyHome;
}
