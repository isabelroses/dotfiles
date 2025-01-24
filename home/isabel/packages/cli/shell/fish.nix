{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
  inherit (lib.strings) optionalString;
in
{
  programs = mkIf config.garden.programs.fish.enable {
    fish = {
      enable = true;
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
        ${getExe pkgs.nix-your-shell} fish | source

        # themeing
        set fish_greeting
        export "MICRO_TRUECOLOR=1"
        set -g theme_display_date no
        set -g theme_nerd_fonts yes
        set -g theme_newline_cursor yes
      '';
    };

    bash.initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${getExe config.programs.fish.package} $LOGIN_OPTION
      fi
    '';
  };
}
