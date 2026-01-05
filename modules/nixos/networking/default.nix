{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkForce;
in
{
  imports = [
    # keep-sorted start
    ./blocker.nix
    ./fail2ban.nix
    ./firewall.nix
    ./networkmanager.nix
    ./openssh.nix
    ./optimise.nix
    ./systemd.nix
    ./tailscale.nix
    ./tcpcrypt.nix
    ./vpn.nix
    ./wireless.nix
    # keep-sorted end
  ];

  networking = {
    # generate a host ID by hashing the hostname
    hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

    # this is setup to use the hostname the system builder provides, this is left here
    # as a note for readers to know this is how it works, and why hostName is never set
    # hostName = "nixos";

    # global dhcp has been deprecated upstream, so we use networkd instead
    # however individual interfaces are still managed through dhcp in hardware configurations
    useDHCP = mkForce false;
    useNetworkd = mkForce true;

    # interfaces are assigned names that contain topology information (e.g. wlp3s0) and thus should be consistent across reboots
    # this already defaults to true, we set it in case it changes upstream
    usePredictableInterfaceNames = mkDefault true;

    # dns
    nameservers = mkIf (!(config ? wsl)) [
      "1.1.1.1"
      "1.0.0.1"
      "9.9.9.9"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
      "2620:fe::fe"
    ];

    # hosts = {
    #   "2a01:4f8:c010:d56::2" = [ "github.com" ];
    #   "2a01:4f8:c010:d56::3" = [ "api.github.com" ];
    #   "2a01:4f8:c010:d56::4" = [ "codeload.github.com" ];
    #   "2a01:4f8:c010:d56::8" = [ "uploads.github.com" ];
    #   "2606:50c0:8000::133" = [
    #     "objects.githubusercontent.com"
    #     "www.objects.githubusercontent.com"
    #     "release-assets.githubusercontent.com"
    #     "gist.githubusercontent.com"
    #     "repository-images.githubusercontent.com"
    #     "camo.githubusercontent.com"
    #     "private-user-images.githubusercontent.com"
    #     "avatars0.githubusercontent.com"
    #     "avatars1.githubusercontent.com"
    #     "avatars2.githubusercontent.com"
    #     "avatars3.githubusercontent.com"
    #     "cloud.githubusercontent.com"
    #     "desktop.githubusercontent.com"
    #   ];
    #   "2606:50c0:8000::154" = [
    #     "support-assets.githubassets.com"
    #     "github.githubassets.com"
    #     "opengraph.githubassets.com"
    #     "github-registry-files.githubusercontent.com"
    #     "github-cloud.githubusercontent.com"
    #   ];
    # };

    enableIPv6 = true;
  };
}
