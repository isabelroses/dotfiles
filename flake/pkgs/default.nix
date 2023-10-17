_: {
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem = {pkgs, ...}: {
    packages = {
      cybershef = pkgs.callPackage ./cyberchef.nix {};
      # https://github.com/NixOS/nixpkgs/issues/195512
    };
  };
}
