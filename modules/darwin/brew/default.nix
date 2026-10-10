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
        tag = "7.0.9";
        hash = "sha256-+7waf1/I5YZPPZOwGDGqhrw9k3lDdXhdk4nglsQcqyA=";
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
          rev = "a0882cbbae13d9802a4472d836b328f8497834bf";
          hash = "sha256-pvHQwCCG4zAfN8RHzM7BygKHbzksAsl3cGNekmkdXVA=";
        };
        "homebrew/homebrew-cask" = pkgs.fetchFromGitHub {
          owner = "homebrew";
          repo = "homebrew-cask";
          rev = "d4d25dbd93eef9ed20f4ae73f3c269a728a412eb";
          hash = "sha256-FkuEIGWiCMhpV7OYfwJUkI7yrHI3AY70KrZ2KnF9hXI=";
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
        # "loungy" # app launcher, too beta to use mainstream
        "gimp" # image editor
        "raycast" # app launcher, and clipboard manager
        # "inkscape" # vector graphics editor
        # "intellij-idea" # IDE
        # "jordanbaird-ice@beta" # better status bar
        "discord"
        "ghostty"
        "helium-browser"
      ];
    };
  };
}
