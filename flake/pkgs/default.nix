_: {
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem = {pkgs, ...}: {
    packages = {
      cybershef = pkgs.callPackage ./cyberchef.nix {};
    };
  };
}
