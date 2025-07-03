{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    getExe
    optionalString
    mapAttrs
    ;

  buildColors =
    opts:
    builtins.concatStringsSep "\n" (
      builtins.attrValues (mapAttrs (name: value: "set fish_color_${name} ${value}") opts)
    );
in
{
  programs.fish = {
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

    shellInit =
      ''
        # themeing
        set fish_greeting
        export "MICRO_TRUECOLOR=1"
        set -g theme_display_date no
        set -g theme_nerd_fonts yes
        set -g theme_newline_cursor yes

        set SHELL ${getExe config.programs.fish.package}
      ''
      + (buildColors {
        # default color
        normal = "brwhite";

        # commands like echo
        command = "yellow";

        # keywords like if - this falls back on the command color if unset
        keyword = "red";

        # quoted text like "abc"
        quote = "green";

        # IO redirections like >/dev/null
        redirection = "magenta";

        # process separators like ; and &
        end = "brwhite";

        # syntax errors
        error = "red";

        # ordinary command parameters
        param = "teal";

        # parameters that are filenames (if the file exists)
        valid_path = "brred";

        # options starting with “-”, up to the first “--” parameter
        option = "teal";

        # comments like ‘# important’
        comment = "brwhite";

        # selected text in vi visual mode
        # selection = "";

        # parameter expansion operators like * and ~
        operator = "brwhite";

        # character escapes like \n and \x70
        escape = "teal";

        # autosuggestions (the proposed rest of a command)
        autosuggestion = "brblack";

        # the current working directory in the default prompt
        cwd = "yellow";

        # the current working directory in the default prompt for the root user
        cwd_root = "blue";

        # the username in the default prompt
        user = "green";

        # the hostname in the default prompt
        host = "magenta";

        # the hostname in the default prompt for remote sessions (like ssh)
        host_remote = "teal";

        # the last command’s nonzero exit code in the default prompt
        status = "red";

        # the ‘^C’ indicator on a canceled command
        cancel = "brblack";

        # history search matches and selected pager items (background only)
        search_match = "brred";

        # the current position in the history
        history_current = "brred";
      });
  };
}
