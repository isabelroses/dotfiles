{osConfig, ...}: {
  programs = let
    inherit (osConfig.age) secrets;
  in {
    ssh = {
      enable = true;
      hashKnownHosts = true;
      compression = true;
      matchBlocks = let
        base = {
          user = "isabel";
        };
        nixSystem =
          base
          // {
            identityFile = secrets.nixos-key.path;
          };
      in {
        # git clients
        "aur.archlinux.org" = {
          user = "aur";
          hostname = "aur.archlinux.org";
          identityFile = secrets.aur-key.path;
        };

        "github.com" = {
          user = "git";
          hostname = "github.com";
          identityFile = secrets.gh-key.path;
        };

        # ORACLE vps'
        "openvpn" = {
          hostname = "132.145.55.42";
          user = "openvpnas";
          identityFile = secrets.openvpn-key.path;
        };

        "amity" =
          base
          // {
            hostname = "143.47.240.116";
            identityFile = secrets.amity-key.path;
          };

        # hetzner cloud vps
        "luz" =
          nixSystem
          // {
            hostname = "91.107.198.173";
          };

        # my local servers / clients
        "hydra" =
          nixSystem
          // {
            hostname = "10.82.7.9";
          };
      };
    };
  };
}
