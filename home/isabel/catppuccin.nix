{
  lib,
  pkgs,
  config,
  inputs,
  options,
  osClass,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkForce;
  inherit (lib.attrsets) mapAttrs;

  isGui = osClass == "nixos" && config.garden.profiles.graphical.enable;

  oled.mocha = {
    base = "000000";
    mantle = "010101";
    crust = "020202";
  };

  hasCtp = osConfig ? "catppuccin";
in
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  config = {
    catppuccin = {
      inherit (config.garden.profiles.workstation) enable;

      flavor = "mocha";
      accent = "pink";

      palette.mocha.colors = mapAttrs (_: v: { hex = mkForce "#${v}"; }) oled.mocha;

      sources =
        if hasCtp then
          osConfig.catppuccin.sources
        else
          (options.catppuccin.sources.default.overrideScope (
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
          ));

      cursors = {
        enable = isGui;
        accent = "dark";
      };

      gtk.icon.enable = isGui;

      # I don't even use the colors from the port
      waybar.enable = false;

      # IFD and can use term colors
      starship.enable = false;

      # IFD and can use term colors
      eza.enable = false;

      # i don't really like the theme here
      mpv.enable = false;
    };
  };
}
