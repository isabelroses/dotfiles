{
  pkgs,
  ...
}: {
    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.utf8";
    virtualisation.docker.enable = true;
    nix = {
        package = pkgs.nixFlakes;
        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            cores = 4;
            max-jobs = "auto";
            sandbox = true;
            auto-optimise-store = true;
            substituters = [
              "https://cache.nixos.org"
              "https://hyprland.cachix.org"
              "https://nix-gaming.cachix.org"
              "https://nix-community.cachix.org"
    	      ];
            trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
              "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
            ];
        };
        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
        };
    };
    system = {
        stateVersion = "23.05";
        autoUpgrade = {
            enable = true;
            channel = "https://nixos.org/channels/nixos-23.05";
        };
    };
    programs.gnupg.agent.enable = true;
    security.polkit.enable = true;
}
