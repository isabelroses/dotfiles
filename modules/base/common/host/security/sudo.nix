{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
in {
  security = {
    # sudo-rs is still a feature-incomplete sudo fork that can and will mess things up
    sudo-rs.enable = lib.mkForce false;

    sudo = {
      enable = true;

      # wheelNeedsPassword = false means wheel group can execute commands without a password
      # so just disable it, it only hurt security, BUT ... see below what commands can be run without password
      wheelNeedsPassword = mkDefault false;

      # only allow members of the wheel group to execute sudo
      execWheelOnly = true;

      # i dont like lectures
      extraConfig = ''
        Defaults lecture = never
        Defaults pwfeedback
        Defaults env_keep += "EDITOR PATH DISPLAY"
        Defaults timestamp_timeout = 300
      '';

      extraRules = [
        {
          # allow wheel group to run nixos-rebuild without password
          groups = ["sudo" "wheel"];
          commands = let
            currentSystem = "/run/current-system/";
            storePath = "/nix/store/";
          in [
            {
              command = "${storePath}/*/bin/switch-to-configuration";
              options = ["SETENV" "NOPASSWD"];
            }
            {
              command = "${currentSystem}/sw/bin/nix-store";
              options = ["SETENV" "NOPASSWD"];
            }
            {
              command = "${currentSystem}/sw/bin/nix-env";
              options = ["SETENV" "NOPASSWD"];
            }
            {
              command = "${currentSystem}/sw/bin/nixos-rebuild";
              options = ["NOPASSWD"];
            }
            {
              # let wheel group collect garbage without password
              command = "${currentSystem}/sw/bin/nix-collect-garbage";
              options = ["SETENV" "NOPASSWD"];
            }
            {
              # let wheel group interact with systemd without password
              command = "${currentSystem}/sw/bin/systemctl";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
  };
}
