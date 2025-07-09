{ self, config, ... }:
let
  inherit (self.lib) mkUserSecret;
  inherit (config.age) secrets;
  inherit (config.home) homeDirectory;
  sshDir = "${homeDirectory}/.ssh";
in
{
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    compression = true;

    includes = [ secrets.uni-ssh.path ];

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

  age.secrets = {
    # keep-sorted start block=yes newline_separated=yes
    keys-amity = mkUserSecret { file = "keys/amity"; };

    keys-aur = mkUserSecret { file = "keys/aur"; };

    keys-aur-pub = mkUserSecret { file = "keys/aur-pub"; };

    keys-codeberg = mkUserSecret { file = "keys/codeberg"; };

    keys-codeberg-pub = mkUserSecret { file = "keys/codeberg-pub"; };

    keys-gh = mkUserSecret { file = "keys/gh"; };

    keys-gh-pub = mkUserSecret { file = "keys/gh-pub"; };

    keys-openvpn = mkUserSecret { file = "keys/openvpn"; };

    keys-tangled = mkUserSecret { file = "keys/tangled"; };

    keys-tangled-pub = mkUserSecret { file = "keys/tangled-pub"; };

    uni-central = mkUserSecret {
      file = "uni/central";
      path = sshDir + "/uni-central";
    };

    uni-gitconf = mkUserSecret { file = "uni/gitconf"; };

    uni-ssh = mkUserSecret { file = "uni/ssh"; };
    # keep-sorted end
  };
}
