{...}: {
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