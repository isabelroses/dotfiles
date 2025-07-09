{ config, ... }:
let
  inherit (config.sops) secrets;
  inherit (config.home) homeDirectory;
  sshDir = "${homeDirectory}/.ssh";
in
{
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    compression = true;

    includes = [ secrets.uni-sshconf.path ];

    matchBlocks = {
      # keep-sorted start block=yes newline_separated=yes
      "amity" = {
        hostname = "143.47.240.116";
        identityFile = secrets.keys-amity.path;
      };

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
        port = 2222;
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

      "hestia".hostname = "116.203.57.153";

      "minerva".hostname = "91.107.198.173";

      "openvpn" = {
        hostname = "132.145.55.42";
        user = "openvpnas";
        identityFile = secrets.keys-openvpn.path;
      };

      "skadi".hostname = "141.147.73.185";

      "tangled.sh" = {
        user = "git";
        hostname = "tangled.sh";
        identityFile = secrets.keys-tangled.path;
      };

      "tatsumaki".hostname = "192.168.1.217";
      # keep-sorted end
    };
  };

  sops.secrets = {
    # keep-sorted start block=yes
    keys-amity = { };
    keys-aur = { };
    keys-aur-pub = { };
    keys-codeberg = { };
    keys-codeberg-pub = { };
    keys-gh = { };
    keys-gh-pub = { };
    keys-openvpn = { };
    keys-tangled = { };
    keys-tangled-pub = { };
    uni-central.path = sshDir + "/uni-central";
    uni-sshconf = { };
    # keep-sorted end
  };
}
