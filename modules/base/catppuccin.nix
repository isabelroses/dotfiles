{
  lib,
  pkgs,
  options,
  ...
}:
{
  catppuccin = {
    enable = true;
    autoEnable = false;

    flavor = "mocha";
    accent = "pink";

    sources = options.catppuccin.sources.default.overrideScope (
      _: _: {
        whiskers = pkgs.symlinkJoin {
          name = "whiskers-wrapped";

          paths = [ pkgs.catppuccin-whiskers ];
          nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

          postBuild = ''
            wrapProgram $out/bin/whiskers \
              --add-flag ${lib.escapeShellArg "--color-overrides=${
                builtins.toJSON {
                  mocha = {
                    base = "000000";
                    mantle = "010101";
                    crust = "020202";
                  };
                }
              }"}
          '';

          meta.mainProgram = "whiskers";
        };
      }
    );
  };
}
