{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkAfter;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.strings) escapeShellArg concatMapStrings;

  cfg = config.garden.programs.nushell;
in
{
  config = mkIf cfg.enable {
    home.packages = [ pkgs.nix-your-shell ];

    programs = {
      bash.initExtra = mkAfter ''
        if [[ $(ps --no-header --pid=$PPID --format=comm) != "nu" && -z ''${BASH_EXECUTION_STRING} ]]; then
           exec ${lib.getExe config.programs.nushell.package}
        fi
      '';

      nushell = {
        enable = true;
        inherit (cfg) package;

        shellAliases = builtins.removeAttrs config.home.shellAliases [ "mkdir" ];

        environmentVariables = {
          DIRENV_LOG_FORMAT = "";
          # PATH = "($env.PATH | split row (char esep) | append [${escapeShellArgs config.home.sessionPath}])";
        } // mapAttrs (_: v: (escapeShellArg v)) config.home.sessionVariables;

        extraConfig =
          let
            completions =
              cmds:
              concatMapStrings (cmd: ''
                source "${pkgs.nu_scripts}/share/nu_scripts/custom-completions/${cmd}/${cmd}-completions.nu"
              '') cmds;

            theme = "catppuccin-${config.catppuccin.flavor}";
          in
          completions [
            "nix"
            "git"
            "curl"
            "bat"
            "cargo"
            "gh"
            "glow"
            "just"
            "rg"
            "npm"
            "pnpm"
            "tar"
          ]
          # nu
          + ''
            use ${pkgs.nu_scripts}/share/nu_scripts/themes/nu-themes/${theme}.nu

            # occasionally generate this with
            # nix-your-shell nu | save $env.XDG_CONFIG_HOME/nushell/nix-your-shell.nu
            source nix-your-shell.nu

            $env.config = {
              show_banner: false,
              rm: {
                always_trash: true
              }
              ls: {
                clickable_links: true
              }
              color_config: (${theme})
              error_style: "fancy"
              completions: {
                case_sensitive: false
                quick: true
                partial: true
                algorithm: "fuzzy"
                use_ls_colors: true
              }
            }
          '';
      };
    };
  };
}
