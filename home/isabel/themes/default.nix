_: {
  imports = [
    ./gtk.nix
    ./qt.nix
  ];
  config.catppuccin = {
    flavour = "mocha";
    accent = "sapphire";
  };
}
