{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (self.lib) mkSecret mkService;

  cfg = config.garden.services.nixpkgs-prs-bot;
in
{
  imports = [
    (mkService "nixpkgs-prs-bot" {
      fedi.enable = false;
      bsky.enable = false;
    })
  ];

  config = mkIf cfg.enable (mkMerge [
    {
      services.nixpkgs-prs-bot.enable = true;
    }

    (mkIf cfg.fedi.enable {
      sops.secrets.nixpkgs-prs-bot-fedi = mkSecret {
        file = "nixpkgs-prs-bot";
        key = "fedi";
      };

      services.nixpkgs-prs-bot.fedi = {
        enable = true;
        environmentFile = config.sops.secrets.nixpkgs-prs-bot-fedi.path;
      };
    })

    (mkIf cfg.bsky.enable {
      sops.secrets.nixpkgs-prs-bot-bsky = mkSecret {
        file = "nixpkgs-prs-bot";
        key = "bsky";
      };

      services.nixpkgs-prs-bot.bsky = {
        enable = true;
        environmentFile = config.sops.secrets.nixpkgs-prs-bot-bsky.path;
      };
    })
  ]);
}
