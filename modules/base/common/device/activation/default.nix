{
  config,
  lib,
  ...
}: {
  system.activationScripts = {
    # if system declares that it wants closure diffs, then run the diff script on activation
    # this is useless if you are using nh, which does this for you in a different way
    diff = lib.mkIf config.modules.system.activation.diffGenerations {
      supportsDryActivation = true;
      text = ''
        if [[ -e /run/current-system ]]; then
          echo "=== diff to current-system ==="
          ${config.nix.package}/bin/nix --extra-experimental-features nix-command store diff-closures /run/current-system "$systemConfig"
          echo "=== end of the system diff ==="
        fi
      '';
    };

    # https://github.com/colemickens/nixcfg/blob/main/mixins/ssh.nix
    # symlink root's ssh config to ours
    # to fix nix-daemon's ability to remote build since it sshs from the root account
    root_ssh_config = let
      sshDir = "/home/${config.modules.system.mainUser}/.ssh";
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
