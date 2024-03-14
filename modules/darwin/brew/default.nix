{
  imports = [./environment.nix];

  config = {
    # homebrew need to be installed manually, see https://brew.sh
    # The apps installed by homebrew are not managed by nix, and not reproducible!
    homebrew = {
      enable = true;
      caskArgs.require_sha = true;

      onActivation = {
        autoUpdate = true;
        upgrade = true;
        # 'zap': uninstalls all formulae(and related files) not listed here.
        cleanup = "zap";
      };

      # Applications to install from Mac App Store using mas.
      # You need to install all these Apps manually first so that your apple account have records for them.
      # otherwise Apple Store will refuse to install them.
      # For details, see https://github.com/mas-cli/mas
      masApps = {};

      taps = [
        "homebrew/bundle"
      ];

      # `brew install`
      brews = [
        "m-cli"
        "coreutils"
        "openjdk"
        "silicon"
      ];

      # `brew install --cask`
      casks = [
        "arc"
        "zed"
        "raycast"
        "intellij-idea"
        "obsidian"
      ];
    };
  };
}
