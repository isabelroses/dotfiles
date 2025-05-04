{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.strings) optionalString;

  cfg = config.garden.wrappers.fish;
  configFile = pkgs.writeTextDir "share/fish/vendor_conf.d/izconfig.fish" cfg.config;
in
{
  config.garden.wrappers.fish = {
    enable = true;
    package = pkgs.fish;

    config = # fish
      ''
        fish_add_path "/run/current-system/sw/bin"
        fish_add_path "/nix/var/nix/profiles/default/bin"
        fish_add_path -p "/etc/profiles/per-user/isabel/bin"

        ${optionalString config.garden.wrappers.starship.enable ''
          if test "$TERM" != "dumb"
            starship init fish | source
          end
        ''}
      '';

    extraWrapperFlags = ''
      --prefix XDG_DATA_DIRS : "${lib.makeSearchPathOutput "out" "share" [ configFile ]}"
    '';
  };
}
