{
  lib,
  pkgs,
  config,
  inputs,
  inputs',
  ...
}:
let
  inherit (lib)
    mkIf
    ldTernary
    mkSecret
    mkSecretWithPath
    ;
  inherit (pkgs.stdenv) isDarwin;

  inherit (config.garden.system) mainUser;
  homeDir = config.home-manager.users.${mainUser}.home.homeDirectory;
  sshDir = homeDir + "/.ssh";

  userGroup = ldTernary pkgs "users" "admin";
in
{
  imports = [ inputs.agenix.nixosModules.default ];

  environment.systemPackages = [ inputs'.agenix.packages.default ];

  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "${sshDir}/id_ed25519"
    ];

    secretsDir = mkIf isDarwin "/private/tmp/agenix";
    secretsMountPoint = mkIf isDarwin "/private/tmp/agenix.d";

    secrets = {
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
    };
  };
}
