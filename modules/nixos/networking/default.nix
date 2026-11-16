{
  lib,
  config,
  ...
}:
let
  inherit (lib.modules) mkDefault mkForce;
  inherit (lib.lists) optionals;
  inherit (lib.options) mkEnableOption;
in
{
  options.garden.system.networking.useRouterDns =
    mkEnableOption "using only the DNS servers handed out by DHCP instead of Quad9";

  imports = [
    # keep-sorted start
    ./blocker.nix
    ./fail2ban.nix
    ./firewall.nix
    ./fleet.nix
    ./networkmanager.nix
    ./openssh.nix
    ./optimise.nix
    ./relay.nix
    ./systemd.nix
    ./tailscale.nix
    ./vpn.nix
    ./wireless.nix
    # keep-sorted end
  ];

  config.networking = {
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

    # dns, left empty on hosts that trust their router's DHCP-provided servers
    nameservers = optionals (!config.garden.system.networking.useRouterDns) [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
  };
}
