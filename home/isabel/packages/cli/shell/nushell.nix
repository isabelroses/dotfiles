{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkAfter;
  inherit (lib.strings) concatMapStrings;

  cfg = config.garden.programs.nushell;

  completions =
    cmds:
    concatMapStrings (cmd: ''
      source "${pkgs.nu_scripts}/share/nu_scripts/custom-completions/${cmd}/${cmd}-completions.nu"
    '') cmds;
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
