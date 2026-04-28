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
      enable = lib.mkDefault (!config.garden.profiles.headless.enable);
      flavor = "mocha";

      sources = options.catppuccin.sources.default.overrideScope (
        _final: prev: {
          whiskers = pkgs.symlinkJoin {
            name = "whiskers-wrapped";

            paths = [ prev.whiskers ];
            nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

            postBuild = ''
              wrapProgram $out/bin/whiskers \
                --add-flag ${lib.escapeShellArg "--color-overrides=${builtins.toJSON oled}"}
            '';

            meta.mainProgram = "whiskers";
          };
        }
      );

      # IFD, easy to vendor
      tty.enable = false;
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
