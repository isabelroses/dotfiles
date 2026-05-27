{
  lib,
  pkgs,
  config,
  inputs,
  options,
  ...
}:
let
  oled = {
    mocha = {
      base = "000000";
      mantle = "010101";
      crust = "020202";
    };
  };
in
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  config = {
    catppuccin = {
      # this option acts more like an auto enable than a blank check enable
      # like other programs. so we can then later pick the ones we want
      enable = false;

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
                --add-flag ${lib.escapeShellArg "--color-overrides=${builtins.toJSON oled}"}
            '';

            meta.mainProgram = "whiskers";
          };
        }
      );

      # pick our ports
      forgejo.enable = true;
    };

    console.colors = lib.mkIf config.catppuccin.enable [
      "000000"
      "f38ba8"
      "a6e3a1"
      "f9e2af"
      "89b4fa"
      "f5c2e7"
      "94e2d5"
      "bac2de"
      "585b70"
      "f38ba8"
      "a6e3a1"
      "f9e2af"
      "89b4fa"
      "f5c2e7"
      "94e2d5"
      "a6adc8"
    ];
  };
}
