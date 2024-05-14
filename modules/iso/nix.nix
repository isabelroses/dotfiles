{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "repl-flake"
    ];
    log-lines = 30;
    extra-experimental-features = [ "ca-derivations" ];
    warn-dirty = false;
    http-connections = 50;
    accept-flake-config = true;
    auto-optimise-store = true;
    trusted-users = [
      "root"
      "nixos"
    ];
  };
}
