{ osConfig, ... }:
let
  inherit (osConfig.age) secrets;
in
{
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    compression = true;

    matchBlocks = {
      # git clients
      "aur.archlinux.org" = {
        user = "aur";
        hostname = "aur.archlinux.org";
        identityFile = secrets.keys-aur.path;
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

      "git.isabelroses.com" = {
        user = "git";
        hostname = "git.isabelroses.com";
        port = 2222;
      };

      "git.auxolotl.org" = {
        user = "forgejo";
        hostname = "git.auxolotl.org";
      };

      # ORACLE vps'
      "openvpn" = {
        hostname = "132.145.55.42";
        user = "openvpnas";
        identityFile = secrets.keys-openvpn.path;
      };

      "amity" = {
        hostname = "143.47.240.116";
        identityFile = secrets.keys-amity.path;
      };

      # hetzner cloud vps
      "luz".hostname = "91.107.198.173";

      # my local servers / clients
      "hydra".hostname = "192.168.86.3";
      "tatsumaki".hostname = "10.82.9.147";
    };
  };
}
