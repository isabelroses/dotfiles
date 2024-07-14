{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf isAcceptedDevice;
  acceptedTypes = [
    "wsl"
    "desktop"
    "laptop"
    "hybrid"
  ];

  cfg = osConfig.garden.programs;
in
{
  programs.direnv = mkIf ((isAcceptedDevice osConfig acceptedTypes) && cfg.cli.enable) {
    enable = true;
    silent = true;

    # faster, persistent implementation of use_nix and use_flake
    nix-direnv.enable = true;

    enableBashIntegration = config.programs.bash.enable;
    # enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableNushellIntegration = config.programs.nushell.enable;

    # modified from from @i077
    # store direnv in cache and not pre project
    stdlib = ''
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs

      direnv_layout_dir() {
        echo "''${direnv_layout_dirs[$PWD]:=$(
          echo -n "$XDG_CACHE_HOME"/direnv/layouts/
          echo -n "$PWD" | ${pkgs.perl}/bin/shasum | cut -d ' ' -f 1
        )}"
      }
    '';
  };
}
