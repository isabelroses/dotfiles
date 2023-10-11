{
  pkgs,
  lib,
  ...
}: {
  security = {
    # sudo-rs is still a feature-incomplete sudo fork that can and will mess things up
    sudo-rs.enable = lib.mkForce false;

    sudo = {
      enable = true;

      # wheelNeedsPassword = false means wheel group can execute commands without a password
      # so just disable it, it only hurt security, BUT ... see below what commands can be run without password
      wheelNeedsPassword = false;

      # only allow members of the wheel group to execute sudo
      execWheelOnly = true;

      # i dont like lectures
      extraConfig = ''
        Defaults lecture = never
        Defaults pwfeedback
        Defaults env_keep += "EDITOR PATH"
        Defaults timestamp_timeout = 300
      '';

      extraRules = [
        {
          # allow wheel group to run nixos-rebuild without password
          groups = ["sudo" "wheel"];
          commands = [
            {
              command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
  };
}
