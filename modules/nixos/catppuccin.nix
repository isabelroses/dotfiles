{
  lib,
  pkgs,
  config,
  inputs,
  options,
  ...
}:
let
  inherit (lib.modules) mkForce;
  inherit (lib.attrsets) mapAttrs;

  oled.mocha = {
    base = "000000";
    mantle = "010101";
    crust = "020202";
  };
in
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  config = {
    catppuccin = {
      enable = lib.mkDefault (!config.garden.profiles.headless.enable);
      flavor = "mocha";

      palette.mocha.colors = mapAttrs (_: v: { hex = mkForce "#${v}"; }) oled.mocha;

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
    };
  };
}
