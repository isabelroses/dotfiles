{
  ...
}: {
  programs.fish = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3"="cd ../../..";
      ".4"="cd ../../../..";
      ".5"="cd ../../../../..";

      # ls to exa
      ls="exa -al --color=always --icons --group-directories-first";
      la="exa -a --color=always --icons --group-directories-first";
      ll="exa -abghHliS --icons --group-directories-first";
      lt="exa -aT --color=always --icons --group-directories-first";

      # confirm
      cp="cp -i";
      mv="mv -i";
      rm="rm -i";
      ln="ln -i";
      
      mkidr="mkdir -pv"; # always create pearent directory
      df="df -h"; # human readblity
      rs="sudo reboot";
      sysctl="sudo systemctl";
      doas="doas --";
      jctl="journalctl -p 3 -xb"; # get error messages from journalctl
      lg="lazygit"; 
    };
    shellInit = ''
      starship init fish | source
      set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
      set TERM "xterm-256color"
      set fish_greeting
      set TERMINAL "alacritty"
      export "MICRO_TRUECOLOR=1"
      export GPG_TTY=$(tty)
      echo y | fish_config theme save theme
    '';
  };
  xdg.configFile."fish/themes/theme.theme" = {
    text = ''
      fish_color_normal cdd6f4
      fish_color_command 89b4fa
      fish_color_param f2cdcd
      fish_color_keyword f38ba8
      fish_color_quote a6e3a1
      fish_color_redirection f5c2e7
      fish_color_end fab387
      fish_color_comment 7f849c
      fish_color_error f38ba8
      fish_color_gray 6c7086
      fish_color_selection --background=313244
      fish_color_search_match --background=313244
      fish_color_option a6e3a1
      fish_color_operator f5c2e7
      fish_color_escape eba0ac
      fish_color_autosuggestion 6c7086
      fish_color_cancel f38ba8
      fish_color_cwd f9e2af
      fish_color_user 94e2d5
      fish_color_host 89b4fa
      fish_color_host_remote a6e3a1
      fish_color_status f38ba8
      fish_pager_color_progress 6c7086
      fish_pager_color_prefix f5c2e7
      fish_pager_color_completion cdd6f4
      fish_pager_color_description 6c7086
    '';
  };
}
