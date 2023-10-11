{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  system.activationScripts.diff = mkIf config.modules.system.activation.diffGenerations {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        echo "=== diff to current-system ==="
        ${config.nix.package}/bin/nix --extra-experimental-features nix-command store diff-closures /run/current-system "$systemConfig"
        echo "=== end of the system diff ==="
      fi
    '';
  };
}
