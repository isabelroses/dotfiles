{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.garden.profiles.workstation.enable {
    garden.packages = {
      chaifetch = pkgs.writeShellApplication {
        name = "chaifetch";
        text = ''
          hyfetch --ascii-file "${./kitty.ascii}" "$@"
        '';
        runtimeInputs = [
          pkgs.hyfetch
          pkgs.fastfetch
        ];
      };
    };

    xdg.configFile."hyfetch.json" = {
      text = ''
        {
            "preset": "lesbian",
            "mode": "rgb",
            "auto_detect_light_dark": false,
            "light_dark": "dark",
            "lightness": 0.65,
            "color_align": {
                "mode": "horizontal"
            },
            "backend": "fastfetch",
            "args": null,
            "distro": "nixos_small",
            "pride_month_disable": false
        }
      '';
    };
  };
}
