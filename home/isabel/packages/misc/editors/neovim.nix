{
  lib,
  pkgs,
  inputs',
  osConfig,
  ...
}:
let
  inherit (lib.lists) optional;
  inherit (lib.meta) getExe;

  nvim = inputs'.izvim.packages.default;

  prgs = osConfig.garden.programs;
  cfg = prgs.neovim;
in
{
  home.packages =
    optional cfg.enable nvim
    ++ optional prgs.gui.enable (
      pkgs.symlinkJoin {
        name = "neovide-wrapped";
        paths = [ pkgs.neovide ];
        nativeBuildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/neovide \
            --add-flags '--frame' \
            --add-flags 'none' \
            --add-flags '--neovim-bin' \
            --add-flags '${getExe nvim}'
        '';
      }
    );
}
