{
  lib,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (lib.programs) mkProgram;
  inherit (lib.meta) getExe;
in
{
  options.garden.programs = {
    vscode = mkProgram pkgs "vscode" { };
    zed = mkProgram pkgs "zed-editor" { };
    micro = mkProgram pkgs "micro" { };

    neovim = mkProgram pkgs "neovim" {
      enable.default = true;
      package.default = inputs'.izvim.packages.default;

      gui = mkProgram pkgs "neovide" {
        enable.default = config.garden.programs.gui.enable;
        package.default = pkgs.symlinkJoin {
          name = "neovide-wrapped";

          paths = [ pkgs.neovide ];
          nativeBuildInputs = [ pkgs.makeWrapper ];

          postBuild = ''
            wrapProgram $out/bin/neovide \
              --add-flags '--frame' \
              --add-flags 'none' \
              --add-flags '--neovim-bin' \
              --add-flags '${getExe config.garden.programs.neovim.package}'
          '';
        };
      };
    };
  };
}
