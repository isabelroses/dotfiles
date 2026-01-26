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
        rev = "d01011cac6d72032c75fd2cd9489909e95d9faf2"; # version 5.0.12
        hash = "sha256-BiGPeulrDVetXP+tjxhMcGLUROZAtZIhU5m4MqawCfM=";
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
          rev = "4d2a2d8fc9d623505079ceafbbd737db551baa41";
          hash = "sha256-lcXa2ypf8YpKl6zn5sJvkXKB7ENMmOEGCZK0ISYQJE0=";
        };
        "homebrew/homebrew-cask" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-cask";
          rev = "c4fea0914d393a384a2ffcf2560fcb6da51925c4";
          hash = "sha256-RaF3hSvG5wLX7pYQ8QdNYzIakTU+MOrqlBRP4SSfqHE=";
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
      brews = [ ];

      # `brew install --cask`
      casks = [
        # "loungy" # app launcher, too beta to use mainstream
        "gimp" # image editor
        "raycast" # app launcher, and clipboard manager
        # "inkscape" # vector graphics editor
        # "intellij-idea" # IDE
        # "jordanbaird-ice@beta" # better status bar
        "discord"
        "ghostty"
        "helium-browser"
        "jellyfin-media-player"
      ];
    };
  };
}
