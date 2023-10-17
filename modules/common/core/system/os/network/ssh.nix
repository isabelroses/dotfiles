{
  config,
  lib,
  ...
}: let
  cfg = config.services.openssh;
in {
  networking.nftables.ruleset = ''
    table inet filter {
      chain input {
        ${lib.concatMapStringsSep "\n" (port: "tcp dport ${builtins.toString port} accept") cfg.ports}
      }
    }
  '';

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = lib.mkDefault false;
      UseDns = false;
      X11Forwarding = false;

      # Use key exchange algorithms recommended by `nixpkgs#ssh-audit`
      # taken from https://github.com/numtide/srvos/blob/main/nixos/common/openssh.nix
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "sntrup761x25519-sha512@openssh.com"
      ];
    };

    # the ssh port(s) should be automatically passed to the firewall's allowedTCPports
    openFirewall = true;
    # the port(s) openssh daemon should listen on
    ports = [22];

    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
