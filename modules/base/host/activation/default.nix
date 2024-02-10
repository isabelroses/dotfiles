{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
  inherit (lib) mkIf;
in {
  system.activationScripts = {
    # if system declares that it wants closure diffs, then run the diff script on activation
    # this is useless if you are using nh, which does this for you in a different way
    diff = mkIf config.modules.system.activation.diffGenerations {
      supportsDryActivation = true;
      text = ''
        if [[ -e /run/current-system ]]; then
          echo "=== diff to current-system ==="
          ${pkgs.nvd}/bin/nvd --nix-bin-dir='${config.nix.package}/bin' diff /run/current-system "$systemConfig"
          echo "=== end of the system diff ==="
        fi
      '';
    };

    # https://github.com/ryan4yin/nix-darwin-kickstarter/blob/main/minimal/modules/system.nix#L14-L19
    postUserActivation = mkIf isDarwin {
      text = ''
        # activateSettings -u will reload the settings from the database and apply them to the current session,
        # so we do not need to logout and login again to make the changes take effect.
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
    };

    # https://github.com/colemickens/nixcfg/blob/main/mixins/ssh.nix
    # symlink root's ssh config to ours
    # to fix nix-daemon's ability to remote build since it sshs from the root account
    root_ssh_config = let
      inherit (config.modules.system) mainUser;

      sshDir = "${config.users.users.${mainUser}.home}/.ssh";
    in {
      text = ''
        (
          # symlink root ssh config to ours so daemon can use our agent/keys/etc...
          mkdir -p /root/.ssh
          ln -sf ${sshDir}/config /root/.ssh/config
          ln -sf ${sshDir}/known_hosts /root/.ssh/known_hosts
          ln -sf ${sshDir}/known_hosts /root/.ssh/known_hosts
        )
      '';
      deps = [];
    };
  };
}
