{ config, ... }:
{
  programs.direnv = {
    inherit (config.garden.profiles.workstation) enable;
    silent = true;

    # faster, persistent implementation of use_nix and use_flake
    nix-direnv.enable = true;

    # modified from @i077
    # store direnv in cache and not per project
    stdlib = ''
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs

      direnv_layout_dir() {
        echo "''${direnv_layout_dirs[$PWD]:=$(
          echo -n "$XDG_CACHE_HOME"/direnv/layouts/
          echo -n "$PWD" | sha1sum | cut -d ' ' -f 1
        )}"
      }
    '';
  };
}
