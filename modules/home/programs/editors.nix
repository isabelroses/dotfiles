{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (self.lib.programs) mkProgram;
  inherit (lib.strings) optionalString concatMapAttrsStringSep;
  inherit (lib.meta) getExe;

  nv = config.garden.programs.neovim;
in
{
  options.garden.programs = {
    vscode = mkProgram pkgs "vscode" { };
    zed = mkProgram pkgs "zed-editor" { };
    micro = mkProgram pkgs "micro" { };

    neovim = mkProgram pkgs "neovim" {
      enable.default = true;

      gui = mkProgram pkgs "neovide" {
        enable.default = config.garden.programs.gui.enable;

        package.default = pkgs.symlinkJoin {
          name = "neovide-wrapped";

          paths = [ pkgs.neovide ];
          nativeBuildInputs = [ pkgs.makeWrapper ];

          postBuild = ''
            wrapProgram $out/bin/neovide \
              --add-flags '--neovim-bin' \
              --add-flags '${getExe nv.package}' \
              ${optionalString (nv.gui.settings != { }) (
                concatMapAttrsStringSep " " (name: value: "--add-flags '${name}=${value}'") nv.gui.settings
              )}
          '';
        };

        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Settings to pass to neovide";
        };
      };
    };
  };
}
