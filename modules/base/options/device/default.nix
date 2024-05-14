{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.modules.device = {
    type = mkOption {
      type = types.enum [
        "laptop"
        "desktop"
        "server"
        "hybrid"
        "wsl"
        "lite"
        "vm"
      ];
      default = "";
    };
  };
}
