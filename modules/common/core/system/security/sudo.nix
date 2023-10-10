{
  pkgs,
  lib,
  ...
}: {
  security = {
    # sudo-rs is still a feature-incomplete sudo fork that can and will mess things up
    sudo-rs.enable = lib.mkForce false;

    # the ol' reliable
    sudo = {
      enable = true;

      # wheelNeedsPassword = false means wheel group can execute commands without a password
      # this is especially useful if you are using --target-host option in nixos-rebuild switch
      # however it's also a massive security flaw - which is why it should be replaced with the
      # extraRules you will see below
      wheelNeedsPassword = false;

      # only allow members of the wheel group to execute sudo
      # by setting the executable’s permissions accordingly
      execWheelOnly = true;

      extraConfig = ''
        Defaults lecture = never # rollback results in sudo lectures after each reboot
        Defaults pwfeedback
        Defaults env_keep += "EDITOR PATH"
        Defaults timestamp_timeout = 300
      '';

      extraRules = [
        {
          # allow wheel group to run nixos-rebuild without password
          # this is a less vulnerable alternative to having wheelNeedsPassword = false
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
