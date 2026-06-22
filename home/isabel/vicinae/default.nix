{
  pkgs,
  config,
  lib,
  ...
}:
let
  mkMyVicinaeExt = pkgs.callPackage ./extension.nix { };
in
{
  programs.vicinae = {
    enable = config.garden.profiles.graphical.enable && pkgs.stdenv.hostPlatform.isLinux;
    systemd.enable = true;

    settings = {
      telemetry.system_info = false;
      pop_to_root_on_close = true;
      theme.dark.name = lib.modules.mkForce "oledpuccin";
      launcher_window = {
        opacity = 1;
        layer_shell.keyboard_interactivity = "on_demand";
      };
    };

    themes.oledpuccin = {
      meta = {
        version = 1;
        name = "oledpuccin";
        description = "catppuccin customised";
        variant = "dark";
        inherits = "catppuccin-mocha";
      };
      colors.core = {
        background = "#000000";
        secondary_background = "#000000";
      };
    };

    # NOTE: I only do it this way because I hate IFD, normal people should use
    # `config.lib.vicinae.mkExtension`
    extensions = map mkMyVicinaeExt [
      {
        extName = "nix";
        npmDepsHash = "sha256-HPWNUznCWVPz39PlPEBR7GpgbC0DuIAvVBdB2GAs47A=";
      }
      {
        extName = "wifi-commander";
        npmDepsHash = "sha256-lP/M+r8Y6j15i8vOxZG75vHUnmVss2gX/5oWvPUft1Q=";
      }
      {
        extName = "bluetooth";
        npmDepsHash = "sha256-WN8tMQIZKr1MjttcFX8ft623gElN0BY9uvEjUpPNjZQ=";
      }
      {
        extName = "pdsls";
        type = "raycast";
        npmDepsHash = "sha256-I+eYqIPvnPOvDRJoS7ootxQ9Kg8FsfaJoT4VcEe+gLM=";
      }

      # broken
      # {
      #   extName = "mullvad";
      #   npmDepsHash = "sha256-WbnZtsTUMDHh2BojAjHUrca8aBw+OGXMMgX79Ek8wQ0=";
      # }
    ];
  };
}
