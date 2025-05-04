{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkAfter mkForce;
  inherit (lib.strings) concatMapStrings;

  cfg = config.garden.programs.nushell;

  completions = concatMapStrings (cmd: ''
    source "${pkgs.nu_scripts}/share/nu_scripts/custom-completions/${cmd}/${cmd}-completions.nu"
  '');
in
{
  config = mkIf cfg.enable {
    home.sessionVariables = {
      GPG_TTY = mkForce "is-terminal";
    };

    programs = {
      bash.initExtra = mkAfter ''
        if [[ $(ps --no-header --pid=$PPID --format=comm) != "nu" && -z ''${BASH_EXECUTION_STRING} ]]; then
           exec ${lib.getExe config.programs.nushell.package}
        fi
      '';

      nushell = {
        enable = true;
        inherit (cfg) package;

        shellAliases = mkForce (
          builtins.removeAttrs config.home.shellAliases [
            "mkdir"
            "zzzpl"
            "zzzbk"
          ]
        );

        settings = {
          show_banner = false;

          rm.always_trash = true;
          ls.clickable_links = true;

          error_style = "fancy";

          completions = {
            case_sensitive = false;
            quick = true;
            partial = true;
            algorithm = "fuzzy";
            use_ls_colors = true;
          };
        };

        extraConfig = completions [
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
        ];
      };
    };
  };
}
