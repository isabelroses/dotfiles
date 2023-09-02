{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.usrEnv.programs.cli.enable) {
    home = {
      packages = with pkgs; [
        alejandra
        deadnix
        nix-index
        nix-tree
        statix
        nil
      ];

      sessionVariables = {
        DIRENV_LOG_FORMAT = "";
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };

      stdlib = ''
        : ''${XDG_CACHE_HOME:=$HOME/.cache}
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
              echo -n "$XDG_CACHE_HOME"/direnv/layouts/
              echo -n "$PWD" | shasum | cut -d ' ' -f 1
          )}"
        }
      '';
    };
  };
}
