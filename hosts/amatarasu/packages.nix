{
  config,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  environment = {
    systemPackages = with pkgs; let 
      gtk = pkgs.catppuccin-gtk.overrideAttrs (final: rec {
        version = "0.6.0";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "gtk";
          rev = "v${version}";
          sha256 = "sha256-3HplAmlj8hK9Myy8mgvR88sMa2COmYAU75Fk1JuKtMc=";
        };
      });
    in [
      (gtk.override {
        accents = ["sapphire"];
        variant = "mocha";
        size = "compact";
      })
      git
      killall
      wget
      home-manager
      pipewire
      wireplumber
      pulseaudio
    ];
  };
}