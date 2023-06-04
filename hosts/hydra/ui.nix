{
  config,
  lib,
  pkgs,
  ...
}: {
  console = {
    font = "RobotoMono Nerd Font";
  };
  fonts.fonts = with pkgs; [
    (nerdfonts.override {fonts = [ "RobotoMono" "JetBrainsMono" "CascadiaCode" "Hack" "Mononoki" "Ubuntu" "UbuntuMono" "Noto" ];})
  ];
  programs = {
    chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
      ];
    };
    gnupg.agent.enable = true;
  };
}