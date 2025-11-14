{ config, ... }:
let
  inherit (config.sops) secrets;
  inherit (config.home) homeDirectory;
  sshDir = "${homeDirectory}/.ssh";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [ secrets.uni-sshconf.path ];

    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = true;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = true;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

      # keep-sorted start block=yes newline_separated=yes
      "amity" = {
        hostname = "143.47.240.116";
        identityFile = secrets.keys-amity.path;
      };

      "aphrodite".hostname = "95.111.208.153";

      "athena".hostname = "192.168.86.3";

      "aur.archlinux.org" = {
        user = "aur";
        hostname = "aur.archlinux.org";
        identityFile = secrets.keys-aur.path;
      };

      "codeberg.org" = {
        user = "git";
        hostname = "codeberg.org";
        identityFile = secrets.keys-codeberg.path;
      };

      "git.auxolotl.org" = {
        user = "forgejo";
        hostname = "git.auxolotl.org";
      };

      "git.isabelroses.com" = {
        user = "git";
        hostname = "git.isabelroses.com";
        identityFile = secrets.keys-git-isabel.path;
      };

      "github.com" = {
        user = "git";
        hostname = "github.com";
        identityFile = secrets.keys-gh.path;
      };

      "gitlab.com" = {
        user = "git";
        hostname = "gitlab.com";
      };

      "isis".hostname = "83.136.254.93";

      "minerva".hostname = "91.107.198.173";

      "openvpn" = {
        hostname = "132.145.55.42";
        user = "openvpnas";
        identityFile = secrets.keys-openvpn.path;
      };

      "skadi".hostname = "141.147.73.185";

      "tangled.org" = {
        user = "git";
        hostname = "tangled.org";
        identityFile = secrets.keys-tangled.path;
      };

      "tatsumaki".hostname = "192.168.1.217";
      # keep-sorted end
    };
  };

  home.file.".ssh/id_ed25519.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMQDiHbMSinj8twL9cTgPOfI6OMexrTZyHX27T8gnMj2
  '';

  sops.secrets = {
    # keep-sorted start block=yes
    keys-amity = { };
    keys-aur = { };
    keys-aur-pub = { };
    keys-codeberg = { };
    keys-codeberg-pub = { };
    keys-gh = { };
    keys-gh-pub = { };
    keys-git-isabel = { };
    keys-openvpn = { };
    keys-tangled = { };
    keys-tangled-pub = { };
    uni-central.path = sshDir + "/uni-central";
    uni-sshconf = { };
    # keep-sorted end
  };
}
