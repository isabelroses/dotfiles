_: {
  programs.fish = {
    enable = true;
    catppuccin.enable = true;
    plugins = [];
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
    shellAbbrs = {};
    shellInit = ''
      starship init fish | source
      set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
      set TERM "xterm-256color"
      set fish_greeting
      set TERMINAL "alacritty"
      export "MICRO_TRUECOLOR=1"
      export GPG_TTY=$(tty)
    '';
  };
}
