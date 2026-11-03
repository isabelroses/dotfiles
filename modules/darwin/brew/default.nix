{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.homebrew.darwinModules.nix-homebrew
    ./environment.nix
  ];

  config = {
    # brought in using nix-homebrew to make homebrew apps reproducible
    nix-homebrew = {
      enable = true;

      package = pkgs.fetchFromGitHub {
        owner = "homebrew";
        repo = "brew";
        tag = "7.0.11";
        hash = "sha256-8mCor0DDjNhi+0e+FllfqiMABujBl+/RxYW+wgMpcto=";
      };

      # I want to force us to only use declarative taps
      mutableTaps = false;

      # we need a user to install the packages for
      user = config.garden.system.mainUser;

      # to truly be declarative, we need to specify the exact revision of homebrew-core
      #
      # you can run the following command to get the latest rev and hash of homebrew-core
      # nix-prefetch-github homebrew homebrew-core --nix
      taps = {
        "homebrew/homebrew-core" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-core";
          rev = "44447c5cdba6a67ce116e4f78bab29b4c69312d7";
          hash = "sha256-Sef2RSF9s24ID91htwuAVGsZZwA+kroBRM77qbbRzT0=";
        };
        "homebrew/homebrew-cask" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-cask";
          rev = "e9707c29ee761b7190f73cc79e56e1033b685cbc";
          hash = "sha256-4zrPeeSgvWGrsZXHtmgEhtR63bi2YWMDk7cu6XlofLI=";
        };
        "abue-ammar/homebrew-tinycast" = pkgs.fetchFromGitHub {
          owner = "abue-ammar";
          repo = "homebrew-tinycast";
          rev = "16a510a98e61b3ff882844c57f5656386735fa8d";
          hash = "sha256-2e24I9zGYRK++ff2wBcj11u7KbapzOYYbI/KRpRMsfc=";
        };
      };
    };

    # without nix-homebrew, these are the apps installed by homebrew
    # are not managed by nix, and not reproducible! But with the use
    # of nix-homebrew, we can manage these apps with nix.
    #
    # for "legacy reasons" you may want to remove nix-homebrew and
    # need to install homebrew manually, see https://brew.sh
    homebrew = {
      enable = true;

      caskArgs.require_sha = true;
      global.autoUpdate = false;

      onActivation = {
        # autoUpdate = true; # this should be managed by nix-homebrew
        upgrade = true;
        # 'zap': uninstalls all formulae (and related files) not listed here.
        cleanup = "zap";
      };

      # Applications to install from Mac App Store using mas.
      # You need to install all these Apps manually first so that your apple account have records for them.
      # otherwise Apple Store will refuse to install them.
      # For details, see https://github.com/mas-cli/mas
      masApps = { };

      # if we don't do this nix-darwin may attempt to remove our taps
      # even when they are managed by nix-homebrew
      taps = builtins.attrNames config.nix-homebrew.taps;

      # `brew install`
      brews = [ "mole" ];

      # `brew install --cask`
      casks = [
        "gimp" # image editor
        # "inkscape" # vector graphics editor
        # "intellij-idea" # IDE
        # "jordanbaird-ice@beta" # better status bar
        "discord"
        "ghostty"
        "helium-browser"
        "abue-ammar/tinycast/tinycast" # native app launcher, raycast replacement
      ];
    };
  };
}
