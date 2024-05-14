{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.direnv = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    nix-direnv.enable = true;

    enableBashIntegration = config.programs.bash.enable;
    # enableFishIntegration = config.programs.fish.enable;
    enableZshIntegration = config.programs.zsh.enable;
    enableNushellIntegration = config.programs.nushell.enable;

    # stdlib = ''
    #   # taken from @i077
    #   # store direnv in cache and not pre project
    #   direnv_layout_dir() {
    #     echo "''${direnv_layout_dirs[$PWD]:=$(
    #       echo -n "${config.xdg.cacheHome}"/direnv/layouts/
    #       echo -n "$PWD" | shasum | cut -d ' ' -f 1
    #     )
    #   }"
    # '';
  };
}
