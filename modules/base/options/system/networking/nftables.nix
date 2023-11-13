{lib, ...}: let
  inherit (lib) mkTable mkPrerouteChain mkForwardChain mkOutputChain mkInputChain mkPostrouteChain mkIngressChain;
in {
  options.networking.nftables.rules = {
    # man nft(8)
    netdev = mkTable "netdev address family netfilter table" {
      filter.ingress = mkIngressChain "netdev";
    };

    bridge = mkTable "bridge address family netfilter table" {
      filter = {
        prerouting = mkPrerouteChain "bridge";
        input = mkInputChain "bridge";
        forward = mkForwardChain "bridge";
        output = mkOutputChain "bridge";
        postrouting = mkPostrouteChain "bridge";
      };
    };

    inet = mkTable "internet (IPv4/IPv6) address family netfilter table" {
      filter = {
        prerouting = mkPrerouteChain "inet";
        input = mkInputChain "inet";
        forward = mkForwardChain "inet";
        output = mkOutputChain "inet";
        postrouting = mkPostrouteChain "inet";
      };

      nat = {
        prerouting = mkPrerouteChain "inet";
        input = mkInputChain "inet";
        output = mkOutputChain "inet";
        postrouting = mkPostrouteChain "inet";
      };
    };

    arp = mkTable "ARP (IPv4) address family netfilter table" {
      filter = {
        input = mkInputChain "arp";
        output = mkOutputChain "arp";
      };
    };

    ip = mkTable "internet (IPv4) address family netfilter table" {
      filter = {
        prerouting = mkPrerouteChain "ip";
        input = mkInputChain "ip";
        forward = mkForwardChain "ip";
        output = mkOutputChain "ip";
        postrouting = mkPostrouteChain "ip";
      };

      nat = {
        prerouting = mkPrerouteChain "ip";
        input = mkInputChain "ip";
        output = mkOutputChain "ip";
        postrouting = mkPostrouteChain "ip";
      };

      route.output = mkForwardChain "ip";
    };

    ip6 = mkTable "internet (IPv6) address family netfilter table" {
      filter = {
        prerouting = mkPrerouteChain "ip6";
        input = mkInputChain "ip6";
        forward = mkForwardChain "ip6";
        output = mkOutputChain "ip6";
        postrouting = mkPostrouteChain "ip6";
      };

      nat = {
        prerouting = mkPrerouteChain "ip6";
        input = mkInputChain "ip6";
        output = mkOutputChain "ip6";
        postrouting = mkPostrouteChain "ip6";
      };

      route.output = mkForwardChain "ip6";
    };
  };
}
