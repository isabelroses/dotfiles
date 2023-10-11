_: {
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem = {pkgs, ...}: {
    packages = {
      cybershef = pkgs.callPackage ./cyberchef.nix {};
      # Stolen from https://github.com/BlankParticle/nixos-flake/blob/d4976617aaa2d2b1f9362fde547f835a4e3bed57/pkgs/discord-krisp-patcher/default.nix
      discord-krisp-patcher = pkgs.callPackage ./discord-krisp-patcher/default.nix {};
    };
  };
}
