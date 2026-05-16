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
  isGui = osClass == "nixos" && config.garden.profiles.graphical.enable;

  oled = {
    mocha = {
      base = "000000";
      mantle = "010101";
      crust = "020202";
    };
  };
in
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  config = {
    catppuccin = {
      inherit (config.garden.profiles.workstation) enable;
      sources =
        if (osConfig ? "catppuccin") then
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

      flavor = "mocha";
      accent = "pink";

      cursors = {
        enable = isGui;
        accent = "dark";
      };

      gtk.icon.enable = isGui;

      # I don't even use the colors from the port
      waybar.enable = false;

      # IFD and can use term colors
      starship.enable = false;

      # IFD and easy enough to vendor
      fzf.enable = false;

      # IFD and can use term colors
      eza.enable = false;

      # i don't really like the theme here
      mpv.enable = false;
    };
  };
}
