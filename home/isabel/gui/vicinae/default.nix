{ pkgs, config, ... }:
let
  mkMyVicinaeExt = pkgs.callPackage ./extension.nix { };
in
{
  programs.vicinae = {
    enable = config.garden.profiles.graphical.enable && pkgs.stdenv.hostPlatform.isLinux;
    systemd.enable = true;

    settings = {
      window.opacity = 1;
    };

    extensions = map mkMyVicinaeExt [
      {
        extName = "nix";
        npmDepsHash = "sha256-HPWNUznCWVPz39PlPEBR7GpgbC0DuIAvVBdB2GAs47A=";
      }
      {
        extName = "wifi-commander";
        npmDepsHash = "sha256-ufVZm0mpRPAgWRXP+h6yNM7cEfM/tdcc0FUBmZiBvBA=";
      }
      {
        extName = "bluetooth";
        npmDepsHash = "sha256-2F7D7DwNG/GAiE+o7srZhcOZzUiRjEVS9uWZAoD7sjo=";
      }
      {
        extName = "pdsls";
        type = "raycast";
        npmDepsHash = "sha256-vx/n64UZBZt1ntPbCILWhp/NJ56zCp9oUTDgqQB8Ny8=";
      }

      # broken
      # {
      #   extName = "mullvad";
      #   npmDepsHash = "sha256-WbnZtsTUMDHh2BojAjHUrca8aBw+OGXMMgX79Ek8wQ0=";
      # }
    ];
  };
}
