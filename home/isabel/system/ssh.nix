{osConfig, ...}: {
  programs.ssh = let
    inherit (osConfig.age) secrets;
  in {
    enable = true;
    hashKnownHosts = true;
    compression = true;

    matchBlocks = {
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

      "git.isabelroses.com" = {
        user = "git";
        hostname = "git.isabelroses.com";
        port = 2222;
      };

      # ORACLE vps'
      "openvpn" = {
        hostname = "132.145.55.42";
        user = "openvpnas";
        identityFile = secrets.openvpn-key.path;
      };

      "amity" = {
        hostname = "143.47.240.116";
        identityFile = secrets.amity-key.path;
      };

      # hetzner cloud vps
      "luz".hostname = "91.107.198.173";

      # my local servers / clients
      "hydra".hostname = "10.82.7.9";
      "tatsumaki".hostname = "10.82.9.147";
    };
  };
}
