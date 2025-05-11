{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkAfter
    mkEnableOption
    ;
in
{
  options.garden.system.activation.diff.enable = mkEnableOption "Enable a system diff" // {
    default = config.garden.profiles.headless.enable;
  };

  # if the system supports dry activation, this means that we can compare
  # the current system with the one we are about to switch to
  # this can be useful to see what will change, and the clousure size
  config = mkIf config.garden.system.activation.diff.enable (mkMerge [
    {
      system.activationScripts.diff = {
        text = ''
          if [[ -e /run/current-system ]]; then
            echo "=== diff to current-system ==="
            ${lib.getExe inputs'.tgirlpkgs.packages.lix-diff} --lix-bin ${config.nix.package}/bin /run/current-system "$systemConfig"
            echo "=== end of the system diff ==="
          fi
        '';
      };
    }

    (mkIf pkgs.stdenv.hostPlatform.isLinux {
      system.activationScripts.diff.supportsDryActivation = true;
    })

    (mkIf pkgs.stdenv.hostPlatform.isDarwin {
      system.activationScripts.postActivation.text = mkAfter ''
        ${config.system.activationScripts.diff.text}
      '';
    })
  ]);
}
