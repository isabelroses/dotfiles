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
      # nix-prefetch-github -- homebrew homebrew-core --nix
      taps = {
        "homebrew/homebrew-core" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-core";
          rev = "a90ad4a0000c75a8eefa306dc6417ea2d81b77a0";
          hash = "sha256-OXuhuiBvbX4D3qlrdhfFTJQvj0hpkWIDRBYcJdgpoH0=";
        };
        "homebrew/homebrew-cask" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-cask";
          rev = "62dc67620117556a71fc5c2cfaccc677cf48c2b2";
          hash = "sha256-dHFn19b3PJ7BiF6tiK3M9bCC7wNOuWYA7kxO5BoCD48=";
        };
        "homebrew/homebrew-bundle" = pkgs.fetchFromGitHub {
          owner = "Homebrew";
          repo = "homebrew-bundle";
          rev = "61fa8774077c9f807639ca2cdc340a0bc3c65964";
          hash = "sha256-UUExG70b1gGlSz06jlvck6au2STfcgPb5eOK79JABxI=";
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
        "raycast" # app launcher, and clipboard manager
        "inkscape" # vector graphics editor
        "intellij-idea" # IDE
        "jordanbaird-ice" # better status bar
      ];
    };
  };
}
