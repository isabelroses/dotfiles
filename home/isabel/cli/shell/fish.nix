{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) optionalString;

  cfg = config.garden.programs.fish;
in
{
  programs.fish = {
    inherit (cfg) enable package;

    plugins = [ ];

    functions = {
      bj = "nohup $argv </dev/null &>/dev/null &";
      "." = ''
        set -l input $argv[1]
        if echo $input | grep -q '^[1-9][0-9]*$'
          set -l levels $input
          for i in (seq $levels)
            cd ..
          end
        else
          echo "Invalid input format. Please use '<number>' to go back a specific number of directories."
        end
      '';
    };

    loginShellInit = optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin 
    '';

    shellInit = ''
      # themeing
      set fish_greeting
      export "MICRO_TRUECOLOR=1"
      set -g theme_display_date no
      set -g theme_nerd_fonts yes
      set -g theme_newline_cursor yes
    '';
  };
}
