_: {
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages = {
      cybershef = pkgs.callPackage ./cyberchef.nix {};
      # https://github.com/NixOS/nixpkgs/issues/195512
      lutgen-rs = pkgs.callPackage ./lutgen-rs.nix {};
      patched-gjs = pkgs.callPackage ./patched-gjs.nix {};

      bellado = inputs'.bellado.packages.default;
      catppuccinifier-cli = inputs'.catppuccinifier.packages.cli;
      ags = inputs'.ags.packages.default;
    };
  };
}
