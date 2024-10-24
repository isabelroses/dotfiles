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
          rev = "7d88d6a70a5688977ad0a72556519607e29f2304";
          hash = "sha256-1V/UU1sFVzvOhmst6VWmpMVj/xFyEHA8FzOmhSh6xbc=";
        };
        "homebrew/homebrew-cask" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-bundle";
          rev = "f3e5960cf1c15f1bfdabe42c173df6592c787249";
          hash = "sha256-g4VI1U6Mq4W2d1cf7S8hyIZbI+DVVwL8RCMCcmzX0Ys=";
        };
        "homebrew/homebrew-bundle" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-bundle";
          rev = "f3e5960cf1c15f1bfdabe42c173df6592c787249";
          hash = "sha256-g4VI1U6Mq4W2d1cf7S8hyIZbI+DVVwL8RCMCcmzX0Ys=";
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
