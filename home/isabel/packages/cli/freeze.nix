{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.validators) isModernShell;
in
{
  config = mkIf (isModernShell config) {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "freeze";
        paths = builtins.attrValues { inherit (pkgs) charm-freeze librsvg; };
      })
    ];

    xdg.configFile."freeze/user.json".text = builtins.toJSON {
      theme = "catppuccin-mocha";
      background = "#1e1e2e";

      window = true;
      shadow = false;
      padding = [
        20
        40
        20
        20
      ];
      margin = 0;

      line_height = 1.2;
      line_numbers = true;

      # border = {
      #   radius = 8;
      #   width = 1;
      #   color = "#313244";
      # };

      font =
        let
          fn = osConfig.garden.style.font;
        in
        {
          family = fn.name;
          inherit (fn) size;
        };
    };
  };
}
