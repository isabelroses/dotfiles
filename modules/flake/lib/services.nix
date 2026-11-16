{ lib }:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkOptionDefault;

  /**
    A module declaring a garden service and its defaults, for a service
    module's imports. The defaults are mkOptionDefault, so anything a host
    sets wins, and they hold while the service is disabled.

    # Arguments

    - [name]: The name of the service
    - [defaults]: Its defaults, e.g. `{ port = 3033; }`

    # Type

    ```
    mkService :: String -> AttrSet -> Module
    ```
  */
  mkService = name: defaults: {
    garden.services.${name} = mapAttrs (_: mkOptionDefault) defaults;
  };
in
{
  inherit mkService;
}
