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
          rev = "e4a6a915ecdff0ed152a80974d119f0e23f5c770";
          hash = "sha256-sF2oYvxFs+JToJADb4ghcipoXkJ5osifFqyPtfATQbE=";
        };
        "homebrew/homebrew-cask" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-cask";
          rev = "6730cf8cf330549a1083643ca64e73fcaca08880";
          hash = "sha256-2bVu+v64NWqCWc55hZ/PEalDlyW661o7eBDgmgnxJYQ=";
        };
        "homebrew/homebrew-bundle" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-bundle";
          rev = "770e3a61ddee249668cd458d7ce124b00fb82e3d";
          hash = "sha256-FqXeSNDCSVJL2eULAndW42do0sYwZgXob6CmqSRjr1U=";
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
      brews = [ "openjdk" ];

      # `brew install --cask`
      casks = [
        "arc" # browser
        # "loungy" # app launcher, too beta to use mainstream
        "gimp" # image editor
        "raycast" # app launcher, and clipboard manager
        "inkscape" # vector graphics editor
        "intellij-idea" # IDE
        "jordanbaird-ice" # better status bar
      ];
    };
  };
}
