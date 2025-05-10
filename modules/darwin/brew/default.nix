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
          rev = "007c32fb9cf6d4b3a2aab14795ec68babf3cb8b1";
          hash = "sha256-qkEb+jJtK6Pl6Oaz48NlkNDNu3ULeua3AyFxxxYGkgQ=";
        };
        "homebrew/homebrew-cask" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-cask";
          rev = "8e15f285b1447529ea73aec436ac94cba2a111c8";
          hash = "sha256-kfTE3gIONZxQsYcrPjFHrp10fgyFA7Nw3Z5m618rrNo=";
        };
        "th-ch/homebrew-youtube-music" = pkgs.fetchFromGitHub {
          owner = "th-ch";
          repo = "homebrew-youtube-music";
          rev = "9ccc1e40dd77c2b21564b470ed9fca50b07bceb1";
          hash = "sha256-XD4ShzgYp4/BLSQO112pXAb5SxGrQr1MRaepfjTB2CA=";
        };
      };
    };

    # without nix-homebrew, these are the apps installed by homebrew
    # are not managed by nix, and not reproducible! But with the use
    # of nix-homebrew, we can manage these apps with nix.
    #
    # for "legeacy reasons" you may want to remove nix-homebrew and
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
      brews = [
        "openjdk@21"
        "openjdk@23"
      ];

      # `brew install --cask`
      casks = [
        "arc" # browser
        # "loungy" # app launcher, too beta to use mainstream
        "gimp" # image editor
        "raycast" # app launcher, and clipboard manager
        "inkscape" # vector graphics editor
        {
          name = "youtube-music";
          args.require_sha = false; # youtube music client
          greedy = true; # ytm is not properly versioned
        }
        "intellij-idea" # IDE
        "jordanbaird-ice" # better status bar
      ];
    };
  };
}
