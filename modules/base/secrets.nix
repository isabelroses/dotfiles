{
  lib,
  self,
  _class,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkMerge getExe;
  inherit (self.lib) mkSecret mkSecretWithPath;

  isDarwin = _class == "darwin";

  inherit (config.garden.system) mainUser;
  homeDir = config.home-manager.users.${mainUser}.home.homeDirectory;
  sshDir = homeDir + "/.ssh";

  userGroup = if isDarwin then "admin" else "users";
in
{
  imports = [ inputs.agenix.nixosModules.default ];

  age = {
    # check the main users ssh key and the system key to see if it is safe
    # to decrypt the secrets
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "${sshDir}/id_ed25519"
    ];

    ageBin = getExe pkgs.rage;

    secretsDir = mkIf isDarwin "/private/tmp/agenix";
    secretsMountPoint = mkIf isDarwin "/private/tmp/agenix.d";

    secrets = mkMerge [
      (mkIf (mainUser == "isabel") {
        wakatime = mkSecretWithPath {
          file = "wakatime";
          path = homeDir + "/.config/wakatime/.wakatime.cfg";
          owner = mainUser;
          group = userGroup;
        };

        # git ssh keys
        keys-gh = mkSecret {
          file = "keys/gh";
          owner = mainUser;
          group = userGroup;
        };
        keys-gh-pub = mkSecret {
          file = "keys/gh-pub";
          owner = mainUser;
          group = userGroup;
        };
        keys-aur = mkSecret {
          file = "keys/aur";
          owner = mainUser;
          group = userGroup;
        };
        keys-aur-pub = mkSecret {
          file = "keys/aur-pub";
          owner = mainUser;
          group = userGroup;
        };

        # extra uni stuff
        uni-gitconf = mkSecret {
          file = "uni/gitconf";
          owner = mainUser;
          group = userGroup;
        };
        uni-ssh = mkSecret {
          file = "uni/ssh";
          owner = mainUser;
          group = userGroup;
        };
        uni-central = mkSecretWithPath {
          file = "uni/central";
          path = sshDir + "/uni-central";
          owner = mainUser;
          group = userGroup;
        };

        # ORACLE vps'
        keys-openvpn = mkSecret {
          file = "keys/openvpn";
          owner = mainUser;
          group = userGroup;
        };
        keys-amity = mkSecret {
          file = "keys/amity";
          owner = mainUser;
          group = userGroup;
        };

        # All nixos machines
        keys-nixos = mkSecretWithPath {
          file = "keys/nixos";
          path = sshDir + "/id_ed25519";
          owner = mainUser;
          group = userGroup;
        };
        keys-nixos-pub = mkSecretWithPath {
          file = "keys/nixos-pub";
          path = sshDir + "/id_ed25519.pub";
          owner = mainUser;
          group = userGroup;
        };
      })

      (mkIf (mainUser == "robin") {
        keys-gpg = mkSecret {
          file = "keys/robin-gpg";
          owner = mainUser;
          group = userGroup;
        };
        keys-gh = mkSecret {
          file = "keys/robin-gh";
          owner = mainUser;
          group = userGroup;
        };
        keys-gh-pub = mkSecret {
          file = "keys/robin-gh-pub";
          owner = mainUser;
          group = userGroup;
        };
        keys-email = mkSecret {
          file = "keys/robin-email";
          owner = mainUser;
          group = userGroup;
        };
      })
    ];
  };
}
