_: {
  # {pkgs, ...}: {
  # home.packages = with pkgs; [cloudflared];
  programs = {
    ssh = {
      enable = true;
      hashKnownHosts = true;
      compression = true;
      matchBlocks = let
        base = {
          user = "isabel";
        };
        template =
          base
          // {
            identityFile = "~/.ssh/nixos";
          };
      in {
        # git clients
        "aur.archlinux.org" = {
          user = "aur";
          hostname = "aur.archlinux.org";
          identityFile = "~/.ssh/aur";
        };

        "github.com" = {
          user = "git";
          hostname = "github.com";
          identityFile = "~/.ssh/github";
        };

        # ORACLE vps'
        "openvpn" = {
          hostname = "132.145.55.42";
          user = "openvpnas";
          identityFile = "~/.ssh/openvpn";
        };

        "amity" =
          base
          // {
            hostname = "143.47.240.116";
            identityFile = "~/.ssh/amity";
          };

        # hetzner cloud vps
        "bernie" =
          template
          // {
            hostname = "91.107.198.173";
          };

        # my local servers / clients
        "hydra" =
          template
          // {
            hostname = "192.168.86.3";
          };

        /*
        "alpha" = {
          hostname = "192.168.86.4";
          user = "isabel";
          identityFile = "~/.ssh/alpha";
        };

        "alpha-remote" = {
          hostname = "ssh.isabelroses.com";
          user = "isabel";
          identityFile = "~/.ssh/alpha";
          proxyCommand = "cloudflared access ssh --hostname %h";
        };
        */
      };
    };
  };
}
