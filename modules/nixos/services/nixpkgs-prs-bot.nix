{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkEnableOption;
  inherit (self.lib) mkServiceOption mkSystemSecret;

  cfg = config.garden.services.nixpkgs-prs-bot;
in
{
  options.garden.services.nixpkgs-prs-bot = mkServiceOption "nixpkgs-prs-bot" {
    extraConfig = {
      fedi.enable = mkEnableOption "fedi";
      bsky.enable = mkEnableOption "bsky";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.nixpkgs-prs-bot.enable = true;
    }

    (mkIf cfg.fedi.enable {
      age.secrets.nixpkgs-prs-bot-fedi = mkSystemSecret {
        file = "nixpkgs-prs-bot/fedi";
        owner = "nixpkgs-prs-bot";
        group = "nixpkgs-prs-bot";
      };

      services.nixpkgs-prs-bot.fedi = {
        enable = true;
        environmentFile = config.age.secrets.nixpkgs-prs-bot-fedi.path;
      };
    })

    (mkIf cfg.bsky.enable {
      age.secrets.nixpkgs-prs-bot-bsky = mkSystemSecret {
        file = "nixpkgs-prs-bot/bsky";
        owner = "nixpkgs-prs-bot";
        group = "nixpkgs-prs-bot";
      };

      services.nixpkgs-prs-bot.bsky = {
        enable = true;
        environmentFile = config.age.secrets.nixpkgs-prs-bot-bsky.path;
      };
    })
  ]);
}
