{ pkgs, config, ... }:
{
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        echo "=== diff to current-system ==="
        ${pkgs.nvd}/bin/nvd --nix-bin-dir='${config.nix.package}/bin' diff /run/current-system "$systemConfig"
        echo "=== end of the system diff ==="
      fi
    '';
  };
}
