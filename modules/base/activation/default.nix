{ config, ... }:
{
  system.activationScripts = {
    # https://github.com/colemickens/nixcfg/blob/main/mixins/ssh.nix
    # symlink root's ssh config to ours
    # to fix nix-daemon's ability to remote build since it sshs from the root account
    root_ssh_config =
      let
        inherit (config.modules.system) mainUser;

        sshDir = "${config.users.users.${mainUser}.home}/.ssh";
      in
      {
        text = ''
          (
            # symlink root ssh config to ours so daemon can use our agent/keys/etc...
            mkdir -p /root/.ssh
            ln -sf ${sshDir}/config /root/.ssh/config
            ln -sf ${sshDir}/known_hosts /root/.ssh/known_hosts
            ln -sf ${sshDir}/known_hosts /root/.ssh/known_hosts
          )
        '';
        deps = [ ];
      };
  };
}
