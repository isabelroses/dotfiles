{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) getExe getExe';
in
{
  # lets swap out our sudo for sudo-rs just like ubuntu does
  # <https://discourse.ubuntu.com/t/adopting-sudo-rs-by-default-in-ubuntu-25-10/60583>
  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = true;

    # only allow members of the wheel group to execute sudo
    execWheelOnly = true;

    # i dont like lectures
    extraConfig = ''
      Defaults !lecture
      Defaults pwfeedback
      Defaults env_keep += "EDITOR PATH DISPLAY"
      Defaults timestamp_timeout = 300
    '';

    extraRules = [
      {
        groups = [ "wheel" ];

        commands = [
          # try to make nixos-rebuild work without password
          {
            command = getExe config.system.build.nixos-rebuild;
            options = [ "NOPASSWD" ];
          }
          {
            command = getExe config.nix.package;
            options = [ "NOPASSWD" ];
          }
          {
            command = getExe' config.nix.package "nix-env";
            options = [ "NOPASSWD" ];
          }
          {
            command = getExe' config.nix.package "nix-store";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/nix/store/*/bin/switch-to-configuration";
            options = [ "NOPASSWD" ];
          }

          # allow reboot and shutdown without password
          {
            command = getExe' pkgs.systemd "systemctl";
            options = [ "NOPASSWD" ];
          }
          {
            command = getExe' pkgs.systemd "reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = getExe' pkgs.systemd "shutdown";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
