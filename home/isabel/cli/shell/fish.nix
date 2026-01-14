{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) optionalString;
in
{
  sops = {
    secrets.env = { };

    templates.fish-env = {
      content = ''
        function setup_secrets_vars;
          if [ -n "$__SECRETS_SOURCED" ]
            return
          end
          set -gx __SECRETS_SOURCED '1'
          ${config.sops.placeholder.env}
        end
        setup_secrets_vars
      '';

      path = "${config.home.homeDirectory}/.config/fish/conf.d/sops-env.fish";
    };
  };

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

    shellInit = ''
      # themeing
      set fish_greeting
      set -g theme_display_date no
      set -g theme_nerd_fonts yes
      set -g theme_newline_cursor yes
    '';
  };
}
