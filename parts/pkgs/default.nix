{self, ...}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages = let
      docs = pkgs.callPackage (self + /docs) {inherit self;};
    in {
      docs-md = docs.md;
      docs-html = docs.html;

      patched-gjs = pkgs.callPackage ./patched-gjs.nix {};
      plymouth-theme-catppuccin = pkgs.callPackage ./plymouth-theme-catppuccin.nix {};
      headscale-ui = pkgs.callPackage ./headscale-ui.nix {};
      gh-eco = pkgs.callPackage ./gh-eco.nix {};
      fork-cleaner = pkgs.callPackage ./fork-cleaner.nix {};
      pace = pkgs.callPackage ./pace.nix {};

      bellado = inputs'.bellado.packages.default;
      izrss = inputs'.izrss.packages.default;
      zzz = inputs'.zzz.packages.default;
      isabelroses-website = inputs'.isabelroses-website.packages.default;
      catppuccinifier-cli = inputs'.catppuccinifier.packages.cli;
    };
  };
}
