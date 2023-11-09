_: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages = {
      cybershef = pkgs.callPackage ./cyberchef.nix {};
      lutgen-rs = pkgs.callPackage ./lutgen-rs.nix {};
      patched-gjs = pkgs.callPackage ./patched-gjs.nix {};
      plymouth-theme-catppuccin = pkgs.callPackage ./plymouth-theme-catppuccin.nix {};

      bellado = inputs'.bellado.packages.default;
      catppuccinifier-cli = inputs'.catppuccinifier.packages.cli;
      ags = inputs'.ags.packages.default;
    };
  };
}
