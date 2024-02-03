{
  imports = [
    ./gtk.nix
    ./qt.nix
    ./global.nix
  ];

  config.catppuccin = {
    flavour = "mocha";
    accent = "sapphire";
  };
}
