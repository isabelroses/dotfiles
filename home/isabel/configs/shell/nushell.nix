{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    getExe
    mapAttrs
    escapeShellArg
    concatMapStrings
    ;
in
{
  programs.nushell = {
    enable = true;

    shellAliases = builtins.removeAttrs config.home.shellAliases [ "mkdir" ];

    environmentVariables = {
      DIRENV_LOG_FORMAT = "''";
      SHELL = "'${getExe pkgs.nushell}'";
      # PATH = "($env.PATH | split row (char esep) | append [${escapeShellArgs config.home.sessionPath}])";
    } // mapAttrs (_: v: (escapeShellArg v)) config.home.sessionVariables;

    extraConfig =
      let
        completions = cmds: ''
          ${concatMapStrings (cmd: ''
            source "${pkgs.nu_scripts}/share/nu_scripts/custom-completions/${cmd}/${cmd}-completions.nu"
          '') cmds}
        '';

        theme = "catppuccin-${config.catppuccin.flavor}";
      in
      ''
        ${completions [
          "nix"
          "git"
          "curl"
          "bat"
          "cargo"
          "gh"
          "glow"
          "just"
          "rg"
        ]}

        use ${pkgs.nu_scripts}/share/nu_scripts/themes/nu-themes/${theme}.nu

        $env.config = {
          show_banner: false,
          rm: {
            always_trash: true
          }
          ls: {
            clickable_links: true
          }
          color_config = (${theme})
          completions: {
            case_sensitive: false
            quick: true
            partial: true
            algorithm: "fuzzy"
          }
        }
      '';
  };
}
