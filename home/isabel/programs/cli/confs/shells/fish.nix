{osConfig, ...}: let
  sys = osConfig.modules.system;
in {
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
    shellAliases = {
      mkidr = "mkdir -pv"; # always create pearent directory
      df = "df -h"; # human readblity
      rs = "sudo reboot";
      sysctl = "sudo systemctl";
      doas = "doas --";
      jctl = "journalctl -p 3 -xb"; # get error messages from journalctl
      lg = "lazygit";

      docker = "podman";
      docker-compose = "podman-compose";

      # nix stuff
      ssp = "~/shells/spawnshell.sh";
      rebuild = "sudo nixos-rebuild switch --flake ${sys.flakePath}#${sys.hostname}";
      nixclean = "sudo nix-collect-garbage --delete-older-than 3d && nix-collect-garbage -d";
      nixrepair = "nix-store --verify --check-contents --repair";
    };
    shellAbbrs = {};
    shellInit = ''
      starship init fish | source
      direnv hook fish | source
      set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
      set TERM "xterm-256color"
      set fish_greeting
      set TERMINAL "alacritty"
      export "MICRO_TRUECOLOR=1"
      export GPG_TTY=$(tty)
    '';
  };
  #xdg.configFile."fish/conf.d" = symlink "home/${sys.username}/programs/cli/confs/fish/conf.d" {recursive = true;};
}
